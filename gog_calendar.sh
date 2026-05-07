#!/bin/bash
# Google Calendar CLI wrapper - uses persistent refresh token
# Usage: gog_calendar [command] [args...]

# Get fresh access token
ACCESS_TOKEN=$(/root/.openclaw/scripts/get_gog_access_token.sh)
if [[ -z "$ACCESS_TOKEN" ]]; then
    echo "Failed to get access token"
    exit 1
fi

# Pass through to Google Calendar API
case "$1" in
    events)
        shift
        # Build query parameters
        QUERY="maxResults=20"
        if [[ "$1" == "--all" ]]; then
            shift
            QUERY="$QUERY&singleEvents=true&orderBy=startTime"
        fi
        if [[ "$1" == "--tomorrow" ]]; then
            TOMORROW=$(date -u -d "+1 day" +%Y-%m-%d)
            QUERY="$QUERY&timeMin=${TOMORROW}T00:00:00Z&timeMax=${TOMORROW}T23:59:59Z"
            shift
        fi
        if [[ "$1" == "--today" || "$1" == "--now" ]]; then
            TODAY=$(date -u +%Y-%m-%d)
            QUERY="$QUERY&timeMin=${TODAY}T00:00:00Z&timeMax=${TODAY}T23:59:59Z"
            shift
        fi
        
        # Make API call
        curl -s "https://www.googleapis.com/calendar/v3/calendars/primary/events?$QUERY" \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            "$@"
        ;;
    *)
        echo "Usage: gog_calendar events [--all|--today|--tomorrow]"
        exit 1
        ;;
esac