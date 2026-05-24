#!/bin/bash

WEBHOOK_URL="http://localhost:5678/webhook/wazuh-alert"
ALERT_FILE="$1"
LOG_FILE="/tmp/custom-n8n.log"

echo "$(date) custom-n8n called with file: $ALERT_FILE" >> "$LOG_FILE"

if grep -Eiq "Logon Failure|eventID\":\"4625|Failed password|Invalid user|authentication failure|sshd" "$ALERT_FILE"; then
  echo "$(date) matched failed login alert" >> "$LOG_FILE"

  curl -s -X POST "$WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    --data-binary @"$ALERT_FILE" >> "$LOG_FILE" 2>&1

  echo "" >> "$LOG_FILE"
else
  echo "$(date) alert ignored" >> "$LOG_FILE"
fi
