################################################################################
#
# inotify-tools
#
################################################################################

INOTIFY_TOOLS_VERSION = 3.20.1
INOTIFY_TOOLS_SITE = $(call github,rvoicilas,inotify-tools,$(INOTIFY_TOOLS_VERSION))
INOTIFY_TOOLS_LICENSE = GPL-2.0+
INOTIFY_TOOLS_LICENSE_FILES = COPYING
INOTIFY_TOOLS_INSTALL_STAGING = YES

define INOTIFY_TOOLS_RUN_AUTOGEN
	cd $(@D) && ./autogen.sh
endef

INOTIFY_TOOLS_PRE_CONFIGURE_HOOKS += INOTIFY_TOOLS_RUN_AUTOGEN

$(eval $(autotools-package))
