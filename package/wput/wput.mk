################################################################################
#
# wput
#
################################################################################

WPUT_VERSION = 0.6.1
WPUT_SOURCE = wput-$(WPUT_VERSION).tgz
WPUT_SITE = https://jaist.dl.sourceforge.net/project/wput/wput/0.6.1
WPUT_DEPENDENCIES = host-pkgconf
WPUT_LICENSE = GPLv2.0
WPUT_LICENSE_FILES = COPYING

ifeq ($(BR2_PACKAGE_GNUTLS),y)
WPUT_CONF_OPTS += \
	--with-gnutls-includes=$(STAGING_DIR)/usr/include \
	--with-gnutls-libs=$(STAGING_DIR)/usr/lib
WPUT_DEPENDENCIES += gnutls
endif

$(eval $(autotools-package))
