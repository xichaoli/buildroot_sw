################################################################################
#
# openvas-scanner
#
################################################################################

OPENVAS_SCANNER_VERSION = 5.0.7
OPENVAS_SCANNER_SOURCE = openvas-scanner-$(OPENVAS_SCANNER_VERSION).tar.gz
OPENVAS_SCANNER_SITE = http://wald.intevation.org/frs/download.php/2367
OPENVAS_SCANNER_INSTALL_STAGING = NO
OPENVAS_SCANNER_INSTALL_TARGET = YES
OPENVAS_SCANNER_DEPENDENCIES = host-pkgconf openvas-libraries
OPENVAS_SCANNER_LICENSE = GPLv2
OPENVAS_SCANNER_LICENSE_FILES = COPYING
OPENVAS_SCANNER_CONF_OPTS = -DGCRYPT_LDFLAGS="-L${STAGING_DIR}/usr/lib -lgcrypt"

$(eval $(cmake-package))
