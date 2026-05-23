# LuCI Theme — Midnight

A dark theme for OpenWrt's LuCI web interface. Deep navy/charcoal palette with green/amber/red health indicators — designed to complement the [Wi-Fi Health Dashboard](https://github.com/naigle/openwrt-wifi-health).

## Preview

| Element | Colour |
|---|---|
| Background | `#0d1117` |
| Surface (panels, nav) | `#161b22` |
| Border | `#30363d` |
| Text | `#e6edf3` |
| OK / success | `#3fb950` |
| Warning | `#d29922` |
| Error / danger | `#f85149` |
| Links / info | `#58a6ff` |

## Requirements

- OpenWrt 24.10 or newer
- `luci-base` (installed by default with LuCI)

## Install

Replace `192.168.1.1` with your router's actual IP address.

### Option 1 — install.sh (recommended)

```sh
curl -sL https://github.com/naigle/luci-theme-midnight/releases/latest/download/install.sh \
  -o install.sh && chmod +x install.sh

# Password auth
./install.sh root@192.168.1.1

# SSH key auth
./install.sh root@192.168.1.1 ~/.ssh/my_router_key
```

### Option 2 — apk package (OpenWrt 24.10+)

```sh
curl -sLO https://github.com/naigle/luci-theme-midnight/releases/latest/download/luci-theme-midnight_1.0.0-r0_all.apk
apk add --allow-untrusted luci-theme-midnight_1.0.0-r0_all.apk
```

### Option 3 — from source (OpenWrt SDK)

```sh
git clone https://github.com/naigle/luci-theme-midnight
# Copy into your OpenWrt package feed, then:
make package/luci-theme-midnight/compile
```

## Revert to default theme

```sh
uci set luci.main.mediaurlbase=/luci-static/bootstrap
uci commit luci
```

Or uninstall:

```sh
# Via apk
apk del luci-theme-midnight

# Manual
ssh root@192.168.1.1 "rm -rf /www/luci-static/midnight /usr/lib/lua/luci/view/themes/midnight"
```

## Compatibility

Tested on:
- **GL.iNet GL-MT6000** (MediaTek MT7986 / Filogic 830)
- **BananaPi BPI-R4** (MediaTek MT7988 / Filogic 880)

Both running OpenWrt 25.12.x.

## License

MIT
