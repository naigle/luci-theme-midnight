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

# ── Install stylesheet ──────────────────────────────────────────
$SSH "$TARGET" "mkdir -p /www/luci-static/midnight /usr/share/ucode/luci/template/themes"

if [ -f "$REPO_DIR/src/luci-static/midnight/cascade.css" ]; then
    $SSH "$TARGET" "cat > /www/luci-static/midnight/cascade.css" \
        < "$REPO_DIR/src/luci-static/midnight/cascade.css"
else
    echo "$CSS_B64" | base64 -d \
        | $SSH "$TARGET" "cat > /www/luci-static/midnight/cascade.css"
fi
echo "  ✓ cascade.css installed"

if [ -f "$REPO_DIR/src/luci-static/midnight/mobile.css" ]; then
    $SSH "$TARGET" "cat > /www/luci-static/midnight/mobile.css" \
        < "$REPO_DIR/src/luci-static/midnight/mobile.css"
else
    echo "$MOBILE_B64" | base64 -d \
        | $SSH "$TARGET" "cat > /www/luci-static/midnight/mobile.css"
fi
echo "  ✓ mobile.css installed"

# ── Symlink ucode templates (midnight → bootstrap) ─────────────
# The ucode LuCI requires a template directory per theme. We reuse
# the bootstrap templates; our cascade.css handles the dark appearance.
$SSH "$TARGET" "ln -sf bootstrap /usr/share/ucode/luci/template/themes/midnight"
echo "  ✓ ucode template symlink created"

# ── Register theme in LuCI config and set as default ───────────
$SSH "$TARGET" "
    # Ensure the themes section exists
    uci -q get luci.themes > /dev/null 2>&1 || uci -q set luci.themes=internal
    # Register the midnight theme
    uci -q set luci.themes.Midnight='/luci-static/midnight'
    # Set as the active theme
    uci -q set luci.main.mediaurlbase='/luci-static/midnight'
    uci -q commit luci
"
echo "  ✓ LuCI theme registered and set to midnight"

# ── Reload web server ──────────────────────────────────────────
$SSH "$TARGET" "/etc/init.d/uhttpd reload 2>/dev/null || true"
echo "  ✓ uhttpd reloaded"

echo ""
echo "Done. Open LuCI — http://${TARGET##*@}/"
echo ""
echo "To revert to the default theme:"
echo "  uci set luci.main.mediaurlbase=/luci-static/bootstrap && uci commit luci"

# Embedded file content (populated by CI — do not edit below this line)
CSS_B64=""
MOBILE_B64=""
