################################################################################
#
# ipset
#
################################################################################

IPSET_VERSION = 6.36
IPSET_SOURCE = ipset-$(IPSET_VERSION).tar.bz2
IPSET_SITE = http://ipset.netfilter.org
IPSET_DEPENDENCIES = libmnl host-pkgconf
IPSET_CONF_OPTS = --with-kmod=no \
	libmnl_CFLAGS="-I${STAGING_DIR}/usr/include" \
	libmnl_LIBS="-L${STAGING_DIR}/usr/lib -lmnl"
IPSET_LICENSE = GPL-2.0
IPSET_LICENSE_FILES = COPYING
IPSET_INSTALL_STAGING = YES


$(eval $(autotools-package))
