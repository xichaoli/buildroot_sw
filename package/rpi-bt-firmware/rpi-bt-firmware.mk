################################################################################
#
# rpi-bt-firmware
#
################################################################################

RPI_BT_FIRMWARE_VERSION = a439f892bf549ddfefa9ba7ad1999cc515f233bf
RPI_BT_FIRMWARE_SITE = https://aur.archlinux.org/pi-bluetooth.git
RPI_BT_FIRMWARE_SITE_METHOD = git
RPI_BT_FIRMWARE_LICENSE = PROPRIETARY
RPI_BT_FIRMWARE_LICENSE_FILES = LICENCE.broadcom_bcm43xx

define RPI_BT_FIRMWARE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/BCM43430A1.hcd \
		$(TARGET_DIR)/lib/firmware/BCM43430A1.hcd
endef

$(eval $(generic-package))
