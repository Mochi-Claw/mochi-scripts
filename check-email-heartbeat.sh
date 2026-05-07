#!/bin/bash
# Mochi's Email Heartbeat - Check inbox and summarize!
# Checks my inbox (buttons@agentmail.to) for fun newsletters

cd /root/.openclaw/workspace

echo "=== MOCHI'S EMAIL CHECK ==="
echo "Checking inbox..."

# Run check_email.js and capture output
RESULT=$(node check_email.js 2>&1)

# Show priority messages if any
echo "$RESULT" | grep -A5 "priority\|unread" | head -20

# Also show what's in the inbox
echo ""
echo "Recent newsletters in inbox:"
node check_email.js 2>&1 | grep -E "from:|subject:|labels:" | head -15

echo ""
echo "📬 Email check complete!"