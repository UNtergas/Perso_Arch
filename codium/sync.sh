#!/bin/bash

set -e

REPO="$HOME/Fun/Perso_Arch"
CODIUM="$REPO/codium"

cd "$REPO"

codium --list-extensions > "$CODIUM/extensions.txt"

git add codium/settings.json \
        codium/keybindings.json \
        codium/extensions.txt

if ! git diff --cached --quiet; then
    git commit -m "Update VSCodium config"
    git push
fi
