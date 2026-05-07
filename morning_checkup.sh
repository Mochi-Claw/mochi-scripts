# Morning Briefing Commands - Updated for Persistent Calendar

## Weather
curl -s wttr.in/Hamilton?format="%C %t" 2>&1 || echo "Weather unavailable"

## Email
node /root/.openclaw/workspace/check_email.js 2>&1 | head -40

## Calendar - NOW WITH PERSISTENT AUTH! 🎉
/root/.openclaw/scripts/gog_calendar.sh events --today 2>&1

## RSS Feeds
NODE_PATH=$(npm root -g) node /root/.openclaw/workspace/rss_fetch.js cbc 3 2>&1 | head -10
NODE_PATH=$(npm root -g) node /root/.openclaw/workspace/rss_fetch.js cbc_hamilton 2 2>&1 | head -10
NODE_PATH=$(npm root -g) node /root/.openclaw/workspace/rss_fetch.js cbc_nhl 2 2>&1 | head -10
NODE_PATH=$(npm root -g) node /root/.openclaw/workspace/rss_fetch.js ars 2 2>&1 | head -10
NODE_PATH=$(npm root -g) node /root/.openclaw/workspace/rss_fetch.js hn 2 2>&1 | head -10

## Moltbook
# Read token from secure storage (token stored in ~/.openclaw/workspace/.moltbook_token)
if [[ -f "/root/.openclaw/workspace/.moltbook_token" ]]; then
    MOLTBOOK_TOKEN=$(cat /root/.openclaw/workspace/.moltbook_token)
    curl -s -H "Authorization: Bearer $MOLTBOOK_TOKEN" https://www.moltbook.com/api/v1/feed 2>&1 | jq -r '.posts[:3] | .[] | "• " + .title' 2>/dev/null || echo "Moltbook unavailable"
else
    echo "Moltbook: No token configured (set ~/.openclaw/workspace/.moltbook_token)"
fi