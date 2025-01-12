#!/bin/bash

# Script to set up the Todoist Telegram bot as a systemd service

BOT_DIR="$HOME/code/my-todoist-telegram-bot"
SECRETS_FILE="/etc/secrets/my-todoist-telegram-bot.conf"
SERVICE_FILE="/etc/systemd/system/my-todoist-telegram-bot.service"
BUNDLE=$(which bundle)

# Secrets

$BUNDLE install || { echo "Bundle install failed"; exit 1; }

sudo mkdir -p /etc/secrets

if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "Creating secrets file: $SECRETS_FILE"
  sudo touch "$SECRETS_FILE"

  echo "Enter Telegram token:"
  read -r -s TELEGRAM_TOKEN
  echo ""

  echo "Enter Todoist token:"
  read -r -s TODOIST_TOKEN
  echo ""

  printf "TELEGRAM_TOKEN=%s\n" "$TELEGRAM_TOKEN" | sudo tee -a "$SECRETS_FILE" > /dev/null
  printf "TODOIST_TOKEN=%s\n" "$TODOIST_TOKEN" | sudo tee -a "$SECRETS_FILE" > /dev/null
fi

sudo chown root:root "$SECRETS_FILE"
sudo chmod 600 "$SECRETS_FILE"

# Service

if [[ ! -f "$SERVICE_FILE" ]]; then
  echo "Creating service file: $SERVICE_FILE"
  cat << EOF | sudo tee "$SERVICE_FILE" > /dev/null
[Unit]
Description=My Todoist Telegram Bot
After=network-online.target

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=$BOT_DIR
ExecStart=$BUNDLE exec ruby bin/bot.rb
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
EnvironmentFile=$SECRETS_FILE

[Install]
WantedBy=multi-user.target
EOF
fi

sudo systemctl daemon-reload
sudo systemctl enable my-todoist-telegram-bot.service
sudo systemctl start my-todoist-telegram-bot.service

echo "Bot setup complete"
