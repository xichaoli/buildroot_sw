################################################################################
#
# libnetfilter_cttimeout
#
################################################################################

LIBNETFILTER_CTTIMEOUT_VERSION = 1.0.0
LIBNETFILTER_CTTIMEOUT_SOURCE = libnetfilter_cttimeout-$(LIBNETFILTER_CTTIMEOUT_VERSION).tar.bz2
LIBNETFILTER_CTTIMEOUT_SITE = http://www.netfilter.org/projects/libnetfilter_cttimeout/files
LIBNETFILTER_CTTIMEOUT_INSTALL_STAGING = YES
LIBNETFILTER_CTTIMEOUT_DEPENDENCIES = host-pkgconf libmnl
LIBNETFILTER_CTTIMEOUT_AUTORECONF = YES
LIBNETFILTER_CTTIMEOUT_LICENSE = GPL-2.0+
LIBNETFILTER_CTTIMEOUT_LICENSE_FILES = COPYING

LIBNETFILTER_CTTIMEOUT_CONF_OPTS += \
	LIBMNL_CFLAGS="-I${STAGING_DIR}/usr/include" \
	LIBMNL_LIBS="-L${STAGING_DIR}/usr/lib"

$(eval $(autotools-package))
