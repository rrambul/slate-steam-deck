#!/usr/bin/env bash
# Deploy Slate to the Steam Deck over SSH (see README → "SSH setup").
# No --delete on purpose: files removed locally must be removed on the Deck by hand.
set -euo pipefail
HOST="${SLATE_HOST:-steamdeck}"
DEST="/home/deck/homebrew/themes/Slate/"
cd "$(dirname "$0")"
ssh "$HOST" "mkdir -p '$DEST'"
rsync -av \
  --exclude='.git' --exclude='.gitignore' --exclude='deploy.sh' \
  --exclude='README.md' --exclude='config_*.json' --exclude='.DS_Store' \
  ./ "$HOST:$DEST"
echo "Deployed to $HOST:$DEST — open CSS Loader and press Refresh."
