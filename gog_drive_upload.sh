#!/bin/bash
# Google Drive upload helper - uses persistent refresh token
# Usage: gog_drive_upload <local_file_path> [remote_name]

CONFIG_FILE="/root/.openclaw/workspace/.gog_refresh_token.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: No refresh token config found"
    exit 1
fi

CLIENT_ID=$(jq -r '.client_id' "$CONFIG_FILE")
CLIENT_SECRET=$(jq -r '.client_secret' "$CONFIG_FILE")
REFRESH_TOKEN=$(jq -r '.refresh_token' "$CONFIG_FILE")

if [[ -z "$1" ]]; then
    echo "Usage: $0 <local_file_path> [remote_name]"
    exit 1
fi

LOCAL_FILE="$1"
REMOTE_NAME="${2:-$(basename "$1")}"

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

# For now, use gog with access token env var
export GOG_ACCESS_TOKEN="$ACCESS_TOKEN"
# Use gog which will pick up the token
# Get email from environment
LEAH_EMAIL="${LEAH_EMAIL:-}"
if [ -z "$LEAH_EMAIL" ]; then
    echo "ERROR: LEAH_EMAIL environment variable not set!"
    exit 1
fi
exec gog -a "$LEAH_EMAIL" drive upload "$LOCAL_FILE"