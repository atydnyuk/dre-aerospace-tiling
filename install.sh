#!/bin/bash
# Creates symlinks so AeroSpace picks up configs from this repo

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

link() {
    local src="$1" dst="$2"
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        echo "Backing up $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    ln -s "$src" "$dst"
    echo "  $dst → $src"
}

echo "Linking AeroSpace config..."
mkdir -p ~/.config/aerospace
link "$REPO_DIR/.aerospace.toml" ~/.aerospace.toml
link "$REPO_DIR/scripts" ~/.config/aerospace/scripts

# Ensure scripts are executable
chmod +x "$REPO_DIR/scripts/"*.sh

echo ""
echo "Done. Reload config with: aerospace reload-config"
