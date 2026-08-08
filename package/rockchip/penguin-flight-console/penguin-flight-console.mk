################################################################################
#
# penguin-flight-console
#
################################################################################

PENGUIN_FLIGHT_CONSOLE_VERSION = 0.1.0
PENGUIN_FLIGHT_CONSOLE_SOURCE = penguin-flight-console-update.tar.gz
PENGUIN_FLIGHT_CONSOLE_SITE = https://gitee.com/ncer/penguin-flight-console/releases/download/v$(PENGUIN_FLIGHT_CONSOLE_VERSION)
PENGUIN_FLIGHT_CONSOLE_STRIP_COMPONENTS = 0
PENGUIN_FLIGHT_CONSOLE_LICENSE = Proprietary
PENGUIN_FLIGHT_CONSOLE_DEPENDENCIES = wpa_supplicant

define PENGUIN_FLIGHT_CONSOLE_BUILD_CMDS
	cd $(@D) && sha256sum -c SHA256SUMS
	test -x $(@D)/scripts/pfc-update.sh || \
		(echo "Missing PowerFin PFC update installer" >&2; false)
endef

define PENGUIN_FLIGHT_CONSOLE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/penguin-flight-console \
		$(TARGET_DIR)/usr/bin/penguin-flight-console
	$(INSTALL) -d \
		$(TARGET_DIR)/usr/libexec/penguin-flight-console/powerfin
	$(INSTALL) -m 0755 $(@D)/scripts/*.sh \
		$(TARGET_DIR)/usr/libexec/penguin-flight-console/powerfin/
	$(INSTALL) -m 0644 $(@D)/board.conf \
		$(TARGET_DIR)/usr/libexec/penguin-flight-console/powerfin/board.conf
endef

define PENGUIN_FLIGHT_CONSOLE_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 \
		$(PENGUIN_FLIGHT_CONSOLE_PKGDIR)/S53penguin-flight-console \
		$(TARGET_DIR)/etc/init.d/S53penguin-flight-console
endef

$(eval $(generic-package))
