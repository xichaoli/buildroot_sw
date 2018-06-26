################################################################################
#
# pixz
#
################################################################################

PIXZ_VERSION = 1.0.6
PIXZ_SITE = https://github.com/vasi/pixz/releases/download/v$(PIXZ_VERSION)
PIXZ_SOURCE = pixz-$(PIXZ_VERSION).tar.xz
PIXZ_DEPENDENCIES = host-pkgconf libarchive xz
HOST_PIXZ_DEPENDENCIES = host-pkgconf host-libarchive host-xz
PIXZ_LICENSE = BSD-2-Clause
PIXZ_LICENSE_FILES = LICENSE

# pixz.1 is actually present, but AC_CHECK_FILE doesn't detect it when
# cross-compiling, which causes configure to try to regenerate it. So give it a
# hint to say that it actually is present.
PIXZ_CONF_ENV = ac_cv_file_src_pixz_1=yes

PIXZ_CONF_OPTS += \
	--with-sysroot=$(STAGING_DIR)/usr \
	CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
	LDFLAGS="-L$(STAGING_DIR)/usr/lib"

$(eval $(autotools-package))
$(eval $(host-autotools-package))
