################################################################################
#
# snort
#
################################################################################

SNORT_VERSION = 2.9.11.1
SNORT_SOURCE = snort-$(SNORT_VERSION).tar.gz
SNORT_SITE = https://www.snort.org/downloads/snort
SNORT_INSTALL_STAGING = NO
SNORT_INSTALL_TARGET = YES
SNORT_DEPENDENCIES = host-pkgconf daq pcre
SNORT_LICENSE = GPLv2
SNORT_LICENSE_FILES = COPYING
SNORT_CONF_ENV = 
SNORT_CONF_OPTS = --enable-gre \
	--enable-ppm \
	--enable-zlib \
	--enable-mpls \
	--enable-react \
	--enable-debug \
	--enable-reload \
	--enable-flexresp3 \
	--enable-normalizer \
	--enable-sourcefire \
	--enable-targetbased \
	--disable-static-daq \
	--enable-perfprofiling \
	--disable-dynamicplugin \
	--enable-decoder-preprocessor-rules \
	--with-libpcap-includes=$(STAGING_DIR)/usr/include \
	--with-libpcap-libraries=$(STAGING_DIR)/usr/lib \
	--with-libpcre-includes=$(STAGING_DIR)/usr/include \
	--with-libpcre-libraries=$(STAGING_DIR)/usr/lib \
	--with-daq-includes=$(STAGING_DIR)/usr/include \
	--with-daq-libraries=$(STAGING_DIR)/usr/lib \
	--with-openssl-includes=$(STAGING_DIR)/usr/include \
	--with-openssl-libraries=$(STAGING_DIR)/usr/lib \
	--cache-file=cross_compile_config.cache

ifeq ($(BR2_PACKAGE_LIBDNET),y)
	SNORT_DEPENDENCIES += libdnet
	SNORT_CONF_OPTS += --with-dnet-includes=$(STAGING_DIR)/usr/include
	SNORT_CONF_OPTS += --with-dnet-libraries=$(STAGING_DIR)/usr/lib
endif

ifeq ($(BR2_PACKAGE_PFRING),y)
	SNORT_DEPENDENCIES += pfring
	SNORT_CONF_OPTS += --with-libpfring-includes=$(STAGING_DIR)/usr/include
	SNORT_CONF_OPTS += --with-libpfring-libraries=$(STAGING_DIR)/usr/lib
endif

$(eval $(autotools-package))
