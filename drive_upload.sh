#!/bin/bash
# Direct Google Drive upload - no gog needed!
# Usage: drive_upload <local_file_path> [folder_name]

CONFIG_FILE="/root/.openclaw/workspace/.gog_refresh_token.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: No refresh token config found at $CONFIG_FILE"
    exit 1
fi

CLIENT_ID=$(jq -r '.client_id' "$CONFIG_FILE")
CLIENT_SECRET=$(jq -r '.client_secret' "$CONFIG_FILE")
REFRESH_TOKEN=$(jq -r '.refresh_token' "$CONFIG_FILE")

if [[ -z "$1" ]]; then
    echo "Usage: $0 <local_file_path> [folder_name]"
    exit 1
fi

LOCAL_FILE="$1"
FOLDER_NAME="${2:-OpenClaw Backups}"

# Get fresh access token
RESPONSE=$(curl -s -X POST "https://oauth2.googleapis.com/token" \
    -d "client_id=$CLIENT_ID" \
    -d "client_secret=$CLIENT_SECRET" \
    -d "refresh_token=$REFRESH_TOKEN" \
    -d "grant_type=refresh_token")

ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.access_token')

if [[ -z "$ACCESS_TOKEN" || "$ACCESS_TOKEN" == "null" ]]; then
    echo "ERROR: Failed to refresh token: $(echo "$RESPONSE" | jq -r '.error')"
    exit 1
fi

# Find or create folder
FOLDER_ID=$(curl -s "https://www.googleapis.com/drive/v3/files?q=name='$FOLDER_NAME'+and+trashed=false+and+mimeType='application/vnd.google-apps.folder'&fields=files(id,name)" \
    -H "Authorization: Bearer $ACCESS_TOKEN" | jq -r '.files[0].id')

if [[ -z "$FOLDER_ID" || "$FOLDER_ID" == "null" ]]; then
    # Create folder
    FOLDER_ID=$(curl -s -X POST "https://www.googleapis.com/drive/v3/files" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$FOLDER_NAME\",\"mimeType\":\"application/vnd.google-apps.folder\"}" | jq -r '.id')
    echo "📁 Created folder '$FOLDER_NAME' (ID: $FOLDER_ID)"
fi

# Upload file
FILENAME=$(basename "$LOCAL_FILE")
echo "📤 Uploading $FILENAME to Google Drive..."

UPLOAD_ID=$(curl -s -X POST "https://www.googleapis.com/upload/drive/v3/files?uploadType=resumable" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"$FILENAME\",\"parents\":[\"$FOLDER_ID\"]}" \
    -D - | grep -i "^location:" | awk '{print $2}' | tr -d '\r\n')

if [[ -z "$UPLOAD_ID" ]]; then
    echo "ERROR: Failed to start upload"
    exit 1
fi

# Upload the actual file
curl -s -X PUT "$UPLOAD_ID" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/octet-stream" \
    --data-binary @"$LOCAL_FILE" > /dev/null

if [[ $? -eq 0 ]]; then
    echo "✅ Successfully uploaded $FILENAME to '$FOLDER_NAME' folder!"
    echo "🔗 https://drive.google.com/drive/folders/$FOLDER_ID"
else
    echo "ERROR: Upload failed"
    exit 1
fi