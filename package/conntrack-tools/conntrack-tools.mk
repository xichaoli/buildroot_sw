################################################################################
#
# conntrack-tools
#
################################################################################

CONNTRACK_TOOLS_VERSION = 1.4.4
CONNTRACK_TOOLS_SOURCE = conntrack-tools-$(CONNTRACK_TOOLS_VERSION).tar.bz2
CONNTRACK_TOOLS_SITE = http://www.netfilter.org/projects/conntrack-tools/files
CONNTRACK_TOOLS_DEPENDENCIES = host-pkgconf \
	libnetfilter_conntrack libnetfilter_cthelper libnetfilter_cttimeout \
	libnetfilter_queue host-bison host-flex
CONNTRACK_TOOLS_LICENSE = GPL-2.0+
CONNTRACK_TOOLS_LICENSE_FILES = COPYING

CONNTRACK_TOOLS_CFLAGS = $(TARGET_CFLAGS)

# Some of conntrack-tools source files include both linux/in.h (via
# linux/netfilter.h for kernel headers >= 4.2) and netinet/in.h, which
# causes some symbol conflicts when musl is used. Defining __GLIBC__
# works around that issue since the kernel headers are prepared to
# avoid redefinition of certain symbols when they see __GLIBC__.
ifeq ($(BR2_TOOLCHAIN_USES_MUSL),y)
CONNTRACK_TOOLS_CFLAGS += -D__GLIBC__
endif

ifeq ($(BR2_PACKAGE_LIBTIRPC),y)
CONNTRACK_TOOLS_CFLAGS += `$(PKG_CONFIG_HOST_BINARY) --cflags libtirpc`
CONNTRACK_TOOLS_DEPENDENCIES += libtirpc host-pkgconf
endif

CONNTRACK_TOOLS_CONF_ENV = CFLAGS="$(CONNTRACK_TOOLS_CFLAGS)" \
	LIBNFNETLINK_CFLAGS="-I${STAGING_DIR}/usr/include" \
	LIBNFNETLINK_LIBS="-L${STAGING_DIR}/usr/lib -lnfnetlink" \
	LIBMNL_CFLAGS="-I${STAGING_DIR}/usr/include" \
	LIBMNL_LIBS="-L${STAGING_DIR}/usr/lib -lmnl" \
	LIBNETFILTER_CONNTRACK_CFLAGS="-I${STAGING_DIR}/usr/include" \
	LIBNETFILTER_CONNTRACK_LIBS="-L${STAGING_DIR}/usr/lib -lnetfilter_conntrack" \
	LIBNETFILTER_CTTIMEOUT_CFLAGS="-I${STAGING_DIR}/usr/include" \
	LIBNETFILTER_CTTIMEOUT_LIBS="-L${STAGING_DIR}/usr/lib -lnetfilter_cttimeout" \
	LIBNETFILTER_CTHELPER_CFLAGS="-I${STAGING_DIR}/usr/include" \
	LIBNETFILTER_CTHELPER_LIBS="-L${STAGING_DIR}/usr/lib -lnetfilter_cthelper" \
	LIBNETFILTER_QUEUE_CFLAGS="-I${STAGING_DIR}/usr/include" \
	LIBNETFILTER_QUEUE_LIBS="-L${STAGING_DIR}/usr/lib -lnetfilter_queue"
	

$(eval $(autotools-package))
