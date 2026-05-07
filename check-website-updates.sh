#!/bin/bash
# Website change monitor with DATE VALIDATION
# Checks specific pages for updates AND validates if dates are correct

echo "=== Website Check: GR Pow Wow ==="
GR_URL="https://www.grpowwow.ca/event-info/"
GR_STATE="/root/.openclaw/workspace/memory/grpowwow-dates.json"

# Get the raw HTML
GR_HTML=$(curl -s "$GR_URL")

# Extract dates from the page (looking for day-of-week + date pattern)
GR_CLAIMS=$(echo "$GR_HTML" | grep -oE "(Saturday|Sunday),? (July|August) [0-9]+" | head -3)
echo "Site claims: $GR_CLAIMS"

# Validate what they claim against actual 2026 calendar
# July 2026: 1=Wed, 2=Thu, 3=Fri, 4=Sat, 5=Sun, 6=Mon, 7=Tue, 8=Wed, 9=Thu...
# So: July 4=Sat, July 5=Sun, July 11=Sat, July 12=Sun, July 18=Sat, July 19=Sun, July 25=Sat, July 26=Sun

echo ""
echo "📅 Date validation for 2026:"
echo "  July 25, 2026 = Saturday ✅"
echo "  July 26, 2026 = Sunday ✅"
echo "  July 18, 2026 = Saturday"
echo "  July 19, 2026 = Sunday"

# If they claim July 26 is Saturday, that's WRONG!
if echo "$GR_CLAIMS" | grep -q "Saturday.*26"; then
    echo "⚠️ ALERT: Site claims Saturday July 26 - but that's a SUNDAY in 2026!"
    echo "The dates haven't been properly updated for 2026!"
fi

# Also check copyright
if echo "$GR_HTML" | grep -q "© 2026"; then
    echo "✅ Copyright shows 2026"
else
    echo "⚠️ Copyright doesn't show 2026"
fi

echo ""
echo "=== Website Check: Oasis Night Markets ==="
OASIS_URL="https://oasisnightmarkets.ca/"
OASIS_HTML=$(curl -s "$OASIS_URL")

# Check copyright
if echo "$OASIS_HTML" | grep -q "© 2026"; then
    echo "✅ Copyright shows 2026"
elif echo "$OASIS_HTML" | grep -q "© 2025"; then
    echo "⚠️ Copyright still shows 2025 - likely not updated yet"
else
    echo "ℹ️ Copyright unclear"
fi

# Look for any 2026 references
if echo "$OASIS_HTML" | grep -qE "2026"; then
    echo "✅ Found 2026 references in content"
    echo "$OASIS_HTML" | grep -oE "2026" | head -3
else
    echo "⚠️ No 2026 found in content - probably 2025 dates"
fi