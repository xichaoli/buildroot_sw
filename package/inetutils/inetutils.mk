################################################################################
#
# inetutils
#
################################################################################

INETUTILS_VERSION = 1.9.4
INETUTILS_SITE = $(BR2_GNU_MIRROR)/inetutils
INETUTILS_SOURCE = inetutils-$(INETUTILS_VERSION).tar.xz
INETUTILS_LICENSE = GPL-3.0+
INETUTILS_LICENSE_FILES = COPYING

INETUTILS_CONF_OPTS = \
	--localstatedir=/var \
	--disable-libls      \
	--disable-servers    \
	--disable-hostname   \
	--disable-ifconfig   \
	--disable-logger     \
	--disable-rcp        \
	--disable-rexec      \
	--disable-rlogin     \
	--disable-rsh        \
	--disable-ping       \
	--disable-ping6      \
	--disable-talk       \
	--disable-traceroute \
	--disable-whois      \
	--disable-ncurses    \
	--disable-readline

$(eval $(autotools-package))
