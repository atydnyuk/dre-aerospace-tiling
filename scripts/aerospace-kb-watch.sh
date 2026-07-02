#!/bin/bash
# Switches the AeroSpace binding mode based on whether the ErgoDox EZ is
# docked: 'ergodox' (Dvorak, via firmware) when connected, 'main' (QWERTY)
# otherwise. Debounced against a state file so `aerospace mode` is only
# called on an actual state change. Intended to run periodically from
# com.dre.aerospace-kb-watch launchd agent.

set -euo pipefail

STATE_FILE="/tmp/aerospace-kb-mode"
AEROSPACE_BIN="${AEROSPACE_BIN:-$(command -v aerospace || echo /opt/homebrew/bin/aerospace)}"
ZSA_VENDOR_ID_DEC=12951 # 0x3297

ergodox_connected() {
    local usb_dump
    usb_dump="$(ioreg -p IOUSB -w0 -l 2>/dev/null)"
    grep -qi "ErgoDox" <<<"$usb_dump" && return 0
    grep -q "\"idVendor\" = $ZSA_VENDOR_ID_DEC" <<<"$usb_dump" && return 0
    return 1
}

check_and_set() {
    local desired="main"
    ergodox_connected && desired="ergodox"

    local current=""
    [ -f "$STATE_FILE" ] && current="$(cat "$STATE_FILE")"

    if [ "$desired" != "$current" ]; then
        "$AEROSPACE_BIN" mode "$desired"
        echo "$desired" > "$STATE_FILE"
    fi
}

check_and_set
