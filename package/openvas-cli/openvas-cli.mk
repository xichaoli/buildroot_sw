################################################################################
#
# openvas-cli
#
################################################################################

OPENVAS_CLI_VERSION = 1.4.5
OPENVAS_CLI_SOURCE = openvas-cli-$(OPENVAS_CLI_VERSION).tar.gz
OPENVAS_CLI_SITE = http://wald.intevation.org/frs/download.php/2397
OPENVAS_CLI_INSTALL_STAGING = NO
OPENVAS_CLI_DEPENDENCIES = host-pkgconf openvas-manager
OPENVAS_CLI_LICENSE = GPLv2
OPENVAS_CLI_LICENSE_FILES = COPYING
OPENVAS_CLI_CONF_OPTS = \
	-DPCAP_CONFIG="${STAGING_DIR}/usr/bin/pcap-config" \
	-DPCAP_LDFLAGS="-L${STAGING_DIR}/usr/lib -lpcap" \
	-DGPGME_LDFLAGS="-L${STAGING_DIR}/usr/lib -lgpgme" \
	-DKSBA_LDFLAGS="-L${STAGING_DIR}/usr/lib -lksba"

$(eval $(cmake-package))
