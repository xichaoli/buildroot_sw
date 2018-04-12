################################################################################
#
# barnyard2
#
################################################################################

BARNYARD2_SITE = https://github.com/firnsy/barnyard2.git
BARNYARD2_SITE_METHOD = git
BARNYARD2_VERSION = master
BARNYARD2_DEPENDENCIES = host-pkgconf snort oracle-mysql
BARNYARD2_LICENSE = GPLv2
BARNYARD2_LICENSE_FILES = COPYING
BARNYARD2_CONF_ENV =
BARNYARD2_CONF_OPTS = \
	--enable-mpls \
	--enable-pthread \
	--sysconfdir=/etc/snort \
	--with-libpcap-includes=$(STAGING_DIR)/usr/include \
	--with-libpcap-libraries=$(STAGING_DIR)/usr/lib \
	--with-mysql=$(STAGING_DIR)/usr \
	--with-mysql-includes=$(STAGING_DIR)/usr/include \
	--with-mysql-libraries=$(STAGING_DIR)/usr/lib \
	--cache-file=cross_compile_config.cache

define BARNYARD2_RUN_AUTOGEN
	cd $(@D) && PATH=$(BR_PATH) ./autogen.sh
endef

BARNYARD2_PRE_CONFIGURE_HOOKS += BARNYARD2_RUN_AUTOGEN

$(eval $(autotools-package))

