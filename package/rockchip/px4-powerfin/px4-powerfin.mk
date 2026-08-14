################################################################################
#
# px4-powerfin
#
################################################################################

PX4_POWERFIN_VERSION = latest
PX4_POWERFIN_SOURCE = px4-powerfin-latest.zip
PX4_POWERFIN_SITE = https://github.com/HumpbackLab/PX4-Autopilot/releases/download
PX4_POWERFIN_LICENSE = BSD-3-Clause
PX4_POWERFIN_LICENSE_FILES = px4/LICENSE
PX4_POWERFIN_DEPENDENCIES = host-patchelf
BR_NO_CHECK_HASH_FOR += $(PX4_POWERFIN_SOURCE)

PX4_POWERFIN_RUNTIME_DIR = $(@D)/px4

define PX4_POWERFIN_FETCH_LATEST_RELEASE
	$(PX4_POWERFIN_PKGDIR)/fetch-latest-release.py \
		--repository HumpbackLab/PX4-Autopilot \
		--output $(PX4_POWERFIN_DL_DIR)/$(PX4_POWERFIN_SOURCE)
endef
PX4_POWERFIN_PRE_DOWNLOAD_HOOKS += PX4_POWERFIN_FETCH_LATEST_RELEASE

define PX4_POWERFIN_EXTRACT_CMDS
	$(UNZIP) $(PX4_POWERFIN_DL_DIR)/$(PX4_POWERFIN_SOURCE) -d $(@D)
endef

define PX4_POWERFIN_INSTALL_TARGET_CMDS
	rm -rf \
		$(TARGET_DIR)/root/px4/bin \
		$(TARGET_DIR)/root/px4/posix-configs \
		$(TARGET_DIR)/root/px4/etc
	mkdir -p $(TARGET_DIR)/root/px4
	cp -a \
		$(PX4_POWERFIN_RUNTIME_DIR)/bin \
		$(PX4_POWERFIN_RUNTIME_DIR)/posix-configs \
		$(PX4_POWERFIN_RUNTIME_DIR)/etc \
		$(TARGET_DIR)/root/px4/
	$(HOST_DIR)/bin/patchelf --remove-rpath \
		$(TARGET_DIR)/root/px4/bin/px4
endef

define PX4_POWERFIN_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(PX4_POWERFIN_PKGDIR)/S12powerfin-px4 \
		$(TARGET_DIR)/etc/init.d/S12powerfin-px4
	$(INSTALL) -D -m 0755 $(PX4_POWERFIN_PKGDIR)/powerfin-time-bootstrap \
		$(TARGET_DIR)/usr/sbin/powerfin-time-bootstrap
endef

$(eval $(generic-package))
