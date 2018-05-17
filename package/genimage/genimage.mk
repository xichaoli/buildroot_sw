################################################################################
#
# genimage
#
################################################################################

GENIMAGE_VERSION = 10
GENIMAGE_SOURCE = genimage-$(GENIMAGE_VERSION).tar.gz
GENIMAGE_SITE = https://github.com/pengutronix/genimage/releases/download/v$(GENIMAGE_VERSION)
HOST_GENIMAGE_DEPENDENCIES = host-pkgconf host-libconfuse
GENIMAGE_LICENSE = GPL-2.0
GENIMAGE_LICENSE_FILES = COPYING

define GENIMAGE_RUN_AUTOGEN
	cd $(@D) && PATH=$(BR_PATH) ./autogen.sh
endef

GENIMAGE_PRE_CONFIGURE_HOOKS += GENIMAGE_RUN_AUTOGEN
HOST_GENIMAGE_PRE_CONFIGURE_HOOKS += GENIMAGE_RUN_AUTOGEN

$(eval $(host-autotools-package))
