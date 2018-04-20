################################################################################
#
# openvas-manager
#
################################################################################

OPENVAS_MANAGER_VERSION = 6.0.9
OPENVAS_MANAGER_SOURCE = openvas-manager-$(OPENVAS_MANAGER_VERSION).tar.gz
OPENVAS_MANAGER_SITE = http://wald.intevation.org/frs/download.php/2359
OPENVAS_MANAGER_INSTALL_STAGING = YES
OPENVAS_MANAGER_INSTALL_TARGET = YES
OPENVAS_MANAGER_DEPENDENCIES = host-pkgconf openvas-scanner sqlite
OPENVAS_MANAGER_LICENSE = GPLv2
OPENVAS_MANAGER_LICENSE_FILES = COPYING
OPENVAS_MANAGER_CONF_OPTS =

$(eval $(cmake-package))
