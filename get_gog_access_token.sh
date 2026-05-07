#!/bin/bash
# Google Calendar Access Token Refresher
# Uses stored refresh token to get fresh access tokens

CONFIG_FILE="/root/.openclaw/workspace/.gog_refresh_token.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: No refresh token config found at $CONFIG_FILE"
    echo "Please run the OAuth flow first."
    exit 1
fi

CLIENT_ID=$(jq -r '.client_id' "$CONFIG_FILE")
CLIENT_SECRET=$(jq -r '.client_secret' "$CONFIG_FILE")
REFRESH_TOKEN=$(jq -r '.refresh_token' "$CONFIG_FILE")

if [[ -z "$REFRESH_TOKEN" || "$REFRESH_TOKEN" == "null" ]]; then
    echo "ERROR: No refresh token in config. Please re-authorize."
    exit 1
fi

# Get fresh access token
RESPONSE=$(curl -s -X POST "https://oauth2.googleapis.com/token" \
    -d "client_id=$CLIENT_ID" \
    -d "client_secret=$CLIENT_SECRET" \
    -d "refresh_token=$REFRESH_TOKEN" \
    -d "grant_type=refresh_token")

if echo "$RESPONSE" | jq -e '.access_token' > /dev/null 2>&1; then
    ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.access_token')
    EXPIRES_IN=$(echo "$RESPONSE" | jq -r '.expires_in // 3600')
    echo "$ACCESS_TOKEN"
    # Optionally cache for later use
    echo "$ACCESS_TOKEN" > /root/.config/gogcli/.last_access_token 2>/dev/null
    exit 0
else
    echo "ERROR: Failed to refresh token"
    echo "$RESPONSE" | jq -r '.error // .message // "Unknown error"'
    exit 1
fi