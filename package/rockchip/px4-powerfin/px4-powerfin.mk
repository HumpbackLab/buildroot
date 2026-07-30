################################################################################
#
# px4-powerfin
#
################################################################################

PX4_POWERFIN_VERSION = local
PX4_POWERFIN_SITE = $(TOPDIR)/../../PX4-Autopilot
PX4_POWERFIN_SITE_METHOD = local
PX4_POWERFIN_OVERRIDE_SRCDIR_RSYNC_EXCLUSIONS = \
	--exclude=/build \
	--exclude=/.codegraph \
	--exclude=/fly.tar
PX4_POWERFIN_LICENSE = BSD-3-Clause
PX4_POWERFIN_LICENSE_FILES = LICENSE
PX4_POWERFIN_DEPENDENCIES = host-cmake host-ninja host-patchelf

PX4_POWERFIN_OUTPUT_DIR = $(@D)/build/humpback_powerfin_default
PX4_POWERFIN_TOOLCHAIN_DIR = $(@D)/buildroot-toolchain

define PX4_POWERFIN_BUILD_CMDS
	mkdir -p $(PX4_POWERFIN_TOOLCHAIN_DIR)
	$(INSTALL) -m 0755 $(PX4_POWERFIN_PKGDIR)/toolchain-wrapper.in \
		$(PX4_POWERFIN_TOOLCHAIN_DIR)/arm-linux-gnueabihf-gcc
	$(INSTALL) -m 0755 $(PX4_POWERFIN_PKGDIR)/toolchain-wrapper.in \
		$(PX4_POWERFIN_TOOLCHAIN_DIR)/arm-linux-gnueabihf-g++
	$(SED) 's|@TARGET_CC@|$(TARGET_CC)|g' \
		$(PX4_POWERFIN_TOOLCHAIN_DIR)/arm-linux-gnueabihf-gcc \
		$(PX4_POWERFIN_TOOLCHAIN_DIR)/arm-linux-gnueabihf-g++
	$(SED) 's|@TARGET_CXX@|$(TARGET_CXX)|g' \
		$(PX4_POWERFIN_TOOLCHAIN_DIR)/arm-linux-gnueabihf-gcc \
		$(PX4_POWERFIN_TOOLCHAIN_DIR)/arm-linux-gnueabihf-g++
	ln -sf $(TARGET_CROSS)gcc-ar \
		$(PX4_POWERFIN_TOOLCHAIN_DIR)/arm-linux-gnueabihf-gcc-ar
	ln -sf $(TARGET_CROSS)gcc-nm \
		$(PX4_POWERFIN_TOOLCHAIN_DIR)/arm-linux-gnueabihf-gcc-nm
	ln -sf $(TARGET_CROSS)gcc-ranlib \
		$(PX4_POWERFIN_TOOLCHAIN_DIR)/arm-linux-gnueabihf-gcc-ranlib
	ln -sf $(TARGET_CROSS)ld \
		$(PX4_POWERFIN_TOOLCHAIN_DIR)/arm-linux-gnueabihf-ld
	ln -sf $(TARGET_CROSS)nm \
		$(PX4_POWERFIN_TOOLCHAIN_DIR)/arm-linux-gnueabihf-nm
	ln -sf $(TARGET_CROSS)objcopy \
		$(PX4_POWERFIN_TOOLCHAIN_DIR)/arm-linux-gnueabihf-objcopy
	ln -sf $(TARGET_CROSS)objdump \
		$(PX4_POWERFIN_TOOLCHAIN_DIR)/arm-linux-gnueabihf-objdump
	ln -sf $(TARGET_CROSS)ranlib \
		$(PX4_POWERFIN_TOOLCHAIN_DIR)/arm-linux-gnueabihf-ranlib
	ln -sf $(TARGET_CROSS)strip \
		$(PX4_POWERFIN_TOOLCHAIN_DIR)/arm-linux-gnueabihf-strip
	$(TARGET_MAKE_ENV) env -u GIT_DIR \
		PATH=$(PX4_POWERFIN_TOOLCHAIN_DIR):$(BR_PATH) \
		PYTHON_EXECUTABLE=/usr/bin/python3 \
		$(MAKE) -C $(@D) humpback_powerfin
endef

define PX4_POWERFIN_INSTALL_TARGET_CMDS
	rm -rf \
		$(TARGET_DIR)/root/px4/bin \
		$(TARGET_DIR)/root/px4/posix-configs \
		$(TARGET_DIR)/root/px4/etc
	mkdir -p $(TARGET_DIR)/root/px4
	cp -a \
		$(PX4_POWERFIN_OUTPUT_DIR)/bin \
		$(@D)/posix-configs \
		$(PX4_POWERFIN_OUTPUT_DIR)/etc \
		$(TARGET_DIR)/root/px4/
	$(HOST_DIR)/bin/patchelf --remove-rpath \
		$(TARGET_DIR)/root/px4/bin/px4
endef

$(eval $(generic-package))
