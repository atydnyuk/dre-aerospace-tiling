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

# Install the LaunchAgent that switches binding modes when the ErgoDox EZ
# is docked/undocked. Generated (not symlinked) because it embeds this
# machine's absolute repo path.
PLIST_LABEL="com.dre.aerospace-kb-watch"
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_LABEL.plist"
mkdir -p "$HOME/Library/LaunchAgents"

echo "Installing LaunchAgent for ErgoDox keyboard-mode watcher..."
cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$REPO_DIR/scripts/aerospace-kb-watch.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>5</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/aerospace-kb-watch.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/aerospace-kb-watch.log</string>
</dict>
</plist>
EOF

launchctl unload "$PLIST_PATH" >/dev/null 2>&1 || true
launchctl load -w "$PLIST_PATH"

echo ""
echo "Done. Reload config with: aerospace reload-config"
