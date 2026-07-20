################################################################################
#
# aic8800-firmware
#
################################################################################

AIC8800_FIRMWARE_VERSION = 6e076049b719ac2ff7ce5c92786a680407b11cdb
AIC8800_FIRMWARE_SITE = $(TOPDIR)/package/rockchip/aic8800-firmware
AIC8800_FIRMWARE_SITE_METHOD = local
AIC8800_FIRMWARE_LICENSE = GPL-2.0
AIC8800_FIRMWARE_LICENSE_FILES = COPYRIGHT.radxa

define AIC8800_FIRMWARE_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/lib/firmware/aic8800_fw/USB/aic8800D80
	cp -a $(@D)/firmware/aic8800D80/. \
		$(TARGET_DIR)/lib/firmware/aic8800_fw/USB/aic8800D80/
endef

$(eval $(generic-package))
