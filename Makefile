include $(TOPDIR)/rules.mk

PKG_NAME:=luci-theme-midnight
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Matt Bird
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/luci-theme-midnight
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Themes
  TITLE:=Midnight — dark theme for LuCI
  DEPENDS:=+luci-base
  URL:=https://github.com/naigle/luci-theme-midnight
endef

define Package/luci-theme-midnight/description
  A dark theme for LuCI inspired by GitHub's dark mode.
  Uses a deep navy/charcoal palette with green/amber/red
  health indicators — consistent with the Wi-Fi Health Dashboard.
endef

define Build/Compile
endef

define Package/luci-theme-midnight/install
	$(INSTALL_DIR) $(1)/www/luci-static/midnight
	$(INSTALL_DATA) ./src/luci-static/midnight/cascade.css \
	                $(1)/www/luci-static/midnight/cascade.css

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/themes/midnight
	$(INSTALL_DATA) ./src/view/themes/midnight/header.htm \
	                $(1)/usr/lib/lua/luci/view/themes/midnight/header.htm
	$(INSTALL_DATA) ./src/view/themes/midnight/footer.htm \
	                $(1)/usr/lib/lua/luci/view/themes/midnight/footer.htm
endef

define Package/luci-theme-midnight/postinst
#!/bin/sh
uci -q set luci.main.mediaurlbase=/luci-static/midnight
uci -q commit luci
exit 0
endef

define Package/luci-theme-midnight/prerm
#!/bin/sh
# Restore bootstrap theme on removal
uci -q set luci.main.mediaurlbase=/luci-static/bootstrap
uci -q commit luci
exit 0
endef

$(eval $(call BuildPackage,luci-theme-midnight))
