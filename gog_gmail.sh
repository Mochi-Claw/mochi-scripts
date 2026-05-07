#!/bin/bash
# Gmail helper - uses persistent refresh token
# Usage: gog_gmail [command] [args...]

CONFIG_FILE="/root/.openclaw/workspace/.gog_refresh_token.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: No refresh token config found"
    exit 1
fi

CLIENT_ID=$(jq -r '.client_id' "$CONFIG_FILE")
CLIENT_SECRET=$(jq -r '.client_secret' "$CONFIG_FILE")
REFRESH_TOKEN=$(jq -r '.refresh_token' "$CONFIG_FILE")

# Get fresh access token
ACCESS_TOKEN=$(curl -s -X POST "https://oauth2.googleapis.com/token" \
    -d "client_id=$CLIENT_ID" \
    -d "client_secret=$CLIENT_SECRET" \
    -d "refresh_token=$REFRESH_TOKEN" \
    -d "grant_type=refresh_token" | jq -r '.access_token')

if [[ -z "$ACCESS_TOKEN" || "$ACCESS_TOKEN" == "null" ]]; then
    echo "ERROR: Failed to get access token"
    exit 1
fi

# Gmail API commands
case "$1" in
    list|search)
        shift
        # Default query if none provided
        QUERY="${1:-in:inbox is:unread}"
        curl -s "https://gmail.googleapis.com/gmail/v1/users/me/messages?q=$(echo "$QUERY" | jq -s -R -r @uri)&maxResults=10" \
            -H "Authorization: Bearer $ACCESS_TOKEN" | jq -r '.messages[]?.id' 2>/dev/null
        ;;
    get)
        MSG_ID="$2"
        if [[ -z "$MSG_ID" ]]; then
            echo "Usage: gog_gmail get <message_id>"
            exit 1
        fi
        curl -s "https://gmail.googleapis.com/gmail/v1/users/me/messages/$MSG_ID?format=full" \
            -H "Authorization: Bearer $ACCESS_TOKEN" | jq -r '.payload.headers[] | select(.name=="Subject" or .name=="From" or .name=="Date") | "\(.name): \(.value)"'
        ;;
    labels)
        curl -s "https://gmail.googleapis.com/gmail/v1/users/me/labels" \
            -H "Authorization: Bearer $ACCESS_TOKEN" | jq -r '.labels[] | "\(.name) (\(.id))"'
        ;;
    *)
        echo "Gmail Helper Commands:"
        echo "  gog_gmail list [query]     - List message IDs (default: unread inbox)"
        echo "  gog_gmail get <msg_id>     - Get message details"
        echo "  gog_gmail labels           - List all labels"
        exit 1
        ;;
esac