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
  --exclude='README.md' --exclude='LICENSE' --exclude='docs/' --exclude='tools/' --exclude='config_*.json' --exclude='.DS_Store' \
  ./ "$HOST:$DEST"
echo "Deployed to $HOST:$DEST"
# Optional auto-refresh (needs node + Decky "Allow Remote CEF Debugging"); falls back to manual.
DECK_ADDR="${SLATE_CEF_HOST:-$(ssh -G "$HOST" | awk '/^hostname /{print $2}')}"
if command -v node >/dev/null && node tools/cssloader-refresh.mjs "$DECK_ADDR" 2>/dev/null; then :
else echo "Open CSS Loader on the Deck and press Refresh."; fi
