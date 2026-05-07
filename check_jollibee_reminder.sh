#!/bin/bash
# Check if today is April 21st and remind about Jollibee!

TODAY=$(date +%m-%d)
if [ "$TODAY" == "04-21" ]; then
    echo "🎉 IT'S JOLLIBEE DAY!!"
    echo "Jollibee x FFXIV collab is NOW LIVE!"
    echo "Get the 'Eat Chicken' emote by buying collaboration meals or merch!"
    echo "Link: https://na.finalfantasyxiv.com/lodestone/topics/detail/2ca9077926ee36f137c7969e60447b75dcaadf17"
fi
