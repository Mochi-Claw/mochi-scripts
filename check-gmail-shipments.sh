#!/bin/bash
# Leah's Gmail Shipments Monitor - checks for important shipping emails
# Scans for messages from dragonflynotifications.awsapps.com and JLCNC
# Auto-labels and stars them, then reports findings

echo "=== SHIPMENTS MONITOR ==="
echo "Checking Gmail for important shipping emails..."

# Search for unread from dragonfly (Dragonfly International) or JLCNC
RESULTS=$(gog -a lia.the.adventurer@gmail.com gmail search "from:dragonflyinternational.com OR from:dragonflynotifications.awsapps.com OR from:JLCNC is:unread" 2>&1)

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
  gog -a lia.the.adventurer@gmail.com gmail messages modify "$msgid" --add "📦 Shipments,IMPORTANT" 2>&1 | grep -v "^$"
done
echo "✅ Labels and stars applied!"

echo ""
echo "📬 Shipments check complete!"