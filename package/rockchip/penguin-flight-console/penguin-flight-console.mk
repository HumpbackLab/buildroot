################################################################################
#
# penguin-flight-console
#
################################################################################

PENGUIN_FLIGHT_CONSOLE_VERSION = refs/remotes/origin/master
PENGUIN_FLIGHT_CONSOLE_SITE = ssh://git@github.com/HumpbackLab/penguin-flight-console.git
PENGUIN_FLIGHT_CONSOLE_SITE_METHOD = git
PENGUIN_FLIGHT_CONSOLE_LICENSE = MIT OR Apache-2.0
PENGUIN_FLIGHT_CONSOLE_DEPENDENCIES = wpa_supplicant

define PENGUIN_FLIGHT_CONSOLE_BUILD_CMDS
	cd $(@D) && ./build-cross.sh
	test -x $(@D)/boards/powerfin/pfc-update.sh || \
		(echo "Missing PowerFin PFC update installer" >&2; false)
endef

define PENGUIN_FLIGHT_CONSOLE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/dist/penguin-flight-console \
		$(TARGET_DIR)/usr/bin/penguin-flight-console
	$(INSTALL) -d \
		$(TARGET_DIR)/usr/libexec/penguin-flight-console/powerfin
	$(INSTALL) -m 0755 $(@D)/boards/powerfin/*.sh \
		$(TARGET_DIR)/usr/libexec/penguin-flight-console/powerfin/
	$(INSTALL) -m 0644 $(@D)/boards/powerfin/board.conf \
		$(TARGET_DIR)/usr/libexec/penguin-flight-console/powerfin/board.conf
endef

define PENGUIN_FLIGHT_CONSOLE_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 \
		$(PENGUIN_FLIGHT_CONSOLE_PKGDIR)/S53penguin-flight-console \
		$(TARGET_DIR)/etc/init.d/S53penguin-flight-console
endef

$(eval $(generic-package))
