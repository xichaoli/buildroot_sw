################################################################################
#
# libnetfilter_queue
#
################################################################################

LIBNETFILTER_QUEUE_VERSION = 1.0.2
LIBNETFILTER_QUEUE_SOURCE = libnetfilter_queue-$(LIBNETFILTER_QUEUE_VERSION).tar.bz2
LIBNETFILTER_QUEUE_SITE = http://www.netfilter.org/projects/libnetfilter_queue/files
LIBNETFILTER_QUEUE_INSTALL_STAGING = YES
LIBNETFILTER_QUEUE_DEPENDENCIES = host-pkgconf libnfnetlink libmnl
LIBNETFILTER_QUEUE_AUTORECONF = YES
LIBNETFILTER_QUEUE_LICENSE = GPL-2.0+
LIBNETFILTER_QUEUE_LICENSE_FILES = COPYING

LIBNETFILTER_QUEUE_CONF_OPTS += \
	LIBNFNETLINK_CFLAGS="-I${STAGING_DIR}/usr/include" \
	LIBNFNETLINK_LIBS="-L${STAGING_DIR}/usr/lib" \
	LIBMNL_CFLAGS="-I${STAGING_DIR}/usr/include" \
	LIBMNL_LIBS="-L${STAGING_DIR}/usr/lib"

$(eval $(autotools-package))
