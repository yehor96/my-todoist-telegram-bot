#!/bin/bash

# Script to update the running Todoist Telegram bot

BOT_DIR="$HOME/code/my-todoist-telegram-bot"
MYTODOIST_SERVICE="my-todoist-telegram-bot.service"

git -C "$BOT_DIR" pull origin main || exit 1
sudo systemctl daemon-reload
(cd "$BOT_DIR" && $(which bundle) install || { echo "Bundle install failed"; exit 1; })
sudo systemctl restart "$MYTODOIST_SERVICE"

echo "Bot update complete"