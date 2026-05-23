#!/usr/bin/env bash
# LuCI Midnight Theme — installer for OpenWrt
# https://github.com/naigle/luci-theme-midnight
#
# Usage:
#   ./install.sh [user@host] [ssh-key]
#
# Defaults: root@192.168.1.1, ~/.ssh/openwrt_router (falls back to password auth)

set -e

TARGET="${1:-root@192.168.1.1}"
KEY="${2:-$HOME/.ssh/openwrt_router}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"

if [ -f "$KEY" ]; then
    SSH="ssh -i $KEY -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10"
else
    SSH="ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10"
fi

echo "LuCI Midnight Theme installer"
echo "  Target : $TARGET"
echo "  SSH key: ${KEY} $([ -f "$KEY" ] && echo '(found)' || echo '(not found, will use password)')"
echo ""

send_file() {
    local src="$1" dst="$2"
    if [ -f "$src" ]; then
        $SSH "$TARGET" "cat > $dst" < "$src"
    else
        local varname="$3"
        echo "${!varname}" | base64 -d | $SSH "$TARGET" "cat > $dst"
    fi
}

$SSH "$TARGET" "mkdir -p /www/luci-static/midnight /usr/lib/lua/luci/view/themes/midnight"

send_file "$REPO_DIR/src/luci-static/midnight/cascade.css" \
          "/www/luci-static/midnight/cascade.css" "CSS_B64"
echo "  ✓ Stylesheet installed"

send_file "$REPO_DIR/src/view/themes/midnight/header.htm" \
          "/usr/lib/lua/luci/view/themes/midnight/header.htm" "HEADER_B64"
echo "  ✓ Header template installed"

send_file "$REPO_DIR/src/view/themes/midnight/footer.htm" \
          "/usr/lib/lua/luci/view/themes/midnight/footer.htm" "FOOTER_B64"
echo "  ✓ Footer template installed"

$SSH "$TARGET" "uci -q set luci.main.mediaurlbase=/luci-static/midnight && uci -q commit luci"
echo "  ✓ LuCI theme set to midnight"

echo ""
echo "Done. Reload LuCI — http://${TARGET##*@}/"
echo "To revert: uci set luci.main.mediaurlbase=/luci-static/bootstrap && uci commit luci"

# Embedded file content (populated by CI — do not edit below this line)
CSS_B64=""
HEADER_B64=""
FOOTER_B64=""
