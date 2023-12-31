################################################################################
#
# cjson
#
################################################################################

CJSON_VERSION = v1.7.5
CJSON_SITE = $(call github,DaveGamble,cjson,$(CJSON_VERSION))
CJSON_INSTALL_STAGING = YES
CJSON_LICENSE = MIT
CJSON_LICENSE_FILES = LICENSE

# Compile cjson_utils
CJSON_CONF_OPTS += \
	-DENABLE_CJSON_UTILS=On

# Set ENABLE_CUSTOM_COMPILER_FLAGS to OFF in particular to disable
# -fstack-protector-strong which depends on BR2_TOOLCHAIN_HAS_SSP
CJSON_CONF_OPTS += \
	-DENABLE_CJSON_TEST=OFF \
	-DENABLE_CUSTOM_COMPILER_FLAGS=OFF

# If BUILD_SHARED_AND_STATIC_LIBS is set to OFF, cjson uses the
# standard BUILD_SHARED_LIBS option which is passed by the
# cmake-package infrastructure.
ifeq ($(BR2_SHARED_STATIC_LIBS),y)
CJSON_CONF_OPTS += -DBUILD_SHARED_AND_STATIC_LIBS=ON
else
CJSON_CONF_OPTS += -DBUILD_SHARED_AND_STATIC_LIBS=OFF
endif

$(eval $(cmake-package))
