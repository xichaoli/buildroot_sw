################################################################################
#
# arp-scan
#
################################################################################

ARP_SCAN_VERSION = 1.9
ARP_SCAN_SITE = https://github.com/royhills/arp-scan/releases/download/$(ARP_SCAN_VERSION)
ARP_SCAN_LICENSE = GPL-3.0+
ARP_SCAN_LICENSE_FILES = COPYING
ARP_SCAN_DEPENDENCIES = libpcap

# 0001-configure-try-linking-to-detect-stack-protector-supp.patch touches acinclude.m4
ARP_SCAN_AUTORECONF = YES

ARP_SCAN_CONF_OPTS = \
	--with-sysroot=$(STAGING_DIR)/usr \
	CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
	LDFLAGS="-L$(STAGING_DIR)/usr/lib"

ifeq ($(BR2_STATIC_LIBS),y)
ARP_SCAN_CONF_OPTS = LIBS="`$(STAGING_DIR)/usr/bin/pcap-config --static --additional-libs`"
endif

ARP_SCAN_CONF_ENV = pgac_cv_snprintf_long_long_int_format='%lld'

$(eval $(autotools-package))
