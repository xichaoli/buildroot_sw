################################################################################
#
# xfsprogs
#
################################################################################

XFSPROGS_VERSION = 4.15.1
XFSPROGS_SITE = $(BR2_KERNEL_MIRROR)/linux/utils/fs/xfs/xfsprogs
XFSPROGS_SOURCE = xfsprogs-$(XFSPROGS_VERSION).tar.xz
XFSPROGS_LICENSE = GPL-2.0, GPL-2.0+, LGPL-2.1 (libhandle, few headers)
XFSPROGS_LICENSE_FILES = doc/COPYING

XFSPROGS_DEPENDENCIES = util-linux

XFSPROGS_CONF_ENV = ac_cv_header_aio_h=yes ac_cv_lib_rt_lio_listio=yes
XFSPROGS_CONF_OPTS = \
	--enable-lib64=no \
	--enable-gettext=no \
	INSTALL_USER=root \
	INSTALL_GROUP=root \
	--enable-static \
	--with-sysroot=$(STAGING_DIR)/usr \
	CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
	LDFLAGS="-L$(STAGING_DIR)/usr/lib"

ifeq ($(BR2_PACKAGE_LIBUNISTRING),y)
XFSPROGS_DEPENDENCIES += libunistring
endif

XFSPROGS_INSTALL_TARGET_OPTS = DIST_ROOT=$(TARGET_DIR) install

$(eval $(autotools-package))
