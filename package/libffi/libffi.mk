################################################################################
#
# libffi
#
################################################################################

LIBFFI_VERSION = 3.1
LIBFFI_SITE = ftp://ourself_mirror/libffi
LIBFFI_SOURCE = libffi-${LIBFFI_VERSION}-sw_64.tar.gz
LIBFFI_LICENSE = MIT
LIBFFI_LICENSE_FILES = LICENSE
LIBFFI_INSTALL_STAGING = YES

define LIBFFI_INSTALL_STAGING_CMDS
	cp -a $(@D)/usr ${STAGING_DIR}
endef

define LIBFFI_INSTALL_TARGET_CMDS
	cp -a $(@D)/usr ${TARGET_DIR}
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
