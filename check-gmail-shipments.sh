#!/bin/bash
# Gmail Shipments Monitor - checks for important shipping emails
# Scans for messages from dragonflynotifications.awsapps.com and JLCNC
# Auto-labels and stars them, then reports findings

# Load environment variables from .env file if present
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
fi

# Get email from environment (set LEAH_EMAIL in .env)
LEAH_EMAIL="${LEAH_EMAIL:-}"
if [ -z "$LEAH_EMAIL" ]; then
    echo "ERROR: LEAH_EMAIL environment variable not set!"
    echo "Please set it (e.g., export LEAH_EMAIL=your_email@gmail.com)"
    exit 1
fi

echo "=== SHIPMENTS MONITOR ==="
echo "Checking Gmail for important shipping emails..."

# Search for unread from dragonfly (Dragonfly International) or JLCNC
RESULTS=$(gog -a "$LEAH_EMAIL" gmail search "from:dragonflyinternational.com OR from:dragonflynotifications.awsapps.com OR from:JLCNC is:unread" 2>&1)

if echo "$RESULTS" | grep -q "No threads found"; then
  echo "✅ No new shipment notifications!"
  exit 0
fi

echo "📦 Found shipment emails:"
echo "$RESULTS" | head -20

# Auto-apply labels and star (heartbeat mode - no prompts)
echo ""
echo "   Applying 📦 Shipments label + star..."
echo "$RESULTS" | grep -oE '[0-9a-f]{12,}' | while read -r msgid; do
  gog -a "$LEAH_EMAIL" gmail messages modify "$msgid" --add "📦 Shipments,IMPORTANT" 2>&1 | grep -v "^$"
done
echo "✅ Labels and stars applied!"

echo ""
echo "📬 Shipments check complete!"