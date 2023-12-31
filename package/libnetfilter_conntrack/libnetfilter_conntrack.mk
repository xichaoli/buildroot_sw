################################################################################
#
# libnetfilter_conntrack
#
################################################################################

LIBNETFILTER_CONNTRACK_VERSION = 1.0.6
LIBNETFILTER_CONNTRACK_SOURCE = libnetfilter_conntrack-$(LIBNETFILTER_CONNTRACK_VERSION).tar.bz2
LIBNETFILTER_CONNTRACK_SITE = http://www.netfilter.org/projects/libnetfilter_conntrack/files
LIBNETFILTER_CONNTRACK_INSTALL_STAGING = YES
LIBNETFILTER_CONNTRACK_DEPENDENCIES = host-pkgconf libnfnetlink libmnl
LIBNETFILTER_CONNTRACK_LICENSE = GPL-2.0+
LIBNETFILTER_CONNTRACK_LICENSE_FILES = COPYING

LIBNETFILTER_CONNTRACK_CONF_OPTS += \
	LIBNFNETLINK_CFLAGS="-I${STAGING_DIR}/usr/include" \
	LIBNFNETLINK_LIBS="-L${STAGING_DIR}/usr/lib" \
	LIBMNL_CFLAGS="-I${STAGING_DIR}/usr/include" \
	LIBMNL_LIBS="-L${STAGING_DIR}/usr/lib"

$(eval $(autotools-package))
