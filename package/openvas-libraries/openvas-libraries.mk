################################################################################
#
# openvas-libraries
#
################################################################################

OPENVAS_LIBRARIES_VERSION = 8.0.8
OPENVAS_LIBRARIES_SOURCE = openvas-libraries-$(OPENVAS_LIBRARIES_VERSION).tar.gz
OPENVAS_LIBRARIES_SITE = http://wald.intevation.org/frs/download.php/2351
OPENVAS_LIBRARIES_INSTALL_STAGING = YES
OPENVAS_LIBRARIES_INSTALL_TARGET = YES
OPENVAS_LIBRARIES_DEPENDENCIES = host-pkgconf libglib2 libgcrypt libgpgme libpcap libksba gnutls hiredis util-linux
OPENVAS_LIBRARIES_LICENSE = GPLv2
OPENVAS_LIBRARIES_LICENSE_FILES = COPYING
OPENVAS_LIBRARIES_CONF_OPTS = \
	-DPCAP_CONFIG="${STAGING_DIR}/usr/bin/pcap-config" \
	-DPCAP_LDFLAGS="-L${STAGING_DIR}/usr/lib -lpcap" \
	-DGPGME_LDFLAGS="-L${STAGING_DIR}/usr/lib -lgpgme" \
	-DKSBA_LDFLAGS="-L${STAGING_DIR}/usr/lib -lksba"

$(eval $(cmake-package))
