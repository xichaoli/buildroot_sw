################################################################################
#
# toolchain-native
#
################################################################################

#
# The basic principle is the following
#
#  1. Copy the libraries needed at runtime to the target directory,
#  $(TARGET_DIR). Obviously, things such as the C library, the dynamic
#  loader and a few other utility libraries are needed if dynamic
#  applications are to be executed on the target system.
#
#  2. Copy the libraries and headers to the staging directory. This
#  will allow all further calls to gcc to be made using --sysroot
#  $(STAGING_DIR), which greatly simplifies the compilation of the
#  packages when using native toolchains. So in the end, only the
#  cross-compiler binaries remains native, all libraries and headers
#  are imported into the Buildroot tree.
#
#  3. Build a toolchain wrapper which executes the native toolchain
#  with a number of arguments (sysroot/march/mtune/..) hardcoded,
#  so we're sure the correct configuration is always used and the
#  toolchain behaves similar to an internal toolchain.
#  This toolchain wrapper and symlinks are installed into
#  $(HOST_DIR)/usr/bin like for the internal toolchains, and the rest
#  of Buildroot is handled identical for the 2 toolchain types.

ifeq ($(BR2_TOOLCHAIN_NATIVE_C_LIBRARY),glibc)
TOOLCHAIN_NATIVE_LIBS += libatomic.so.* libc.so.* libcrypt.so.* libdl.so.* libgcc_s.so.* libm.so.* libnsl.so.* libresolv.so.* librt.so.* libutil.so.* ld*.so.*
ifeq ($(BR2_TOOLCHAIN_HAS_THREADS),y)
TOOLCHAIN_NATIVE_LIBS += libpthread.so.*
ifneq ($(BR2_PACKAGE_GDB)$(BR2_TOOLCHAIN_NATIVE_GDB_SERVER_COPY),)
TOOLCHAIN_NATIVE_LIBS += libthread_db.so.*
endif # gdbserver
endif # ! no threads
endif

ifeq ($(BR2_TOOLCHAIN_NATIVE_C_LIBRARY),glibc)
TOOLCHAIN_NATIVE_LIBS += libnss_files.so.* libnss_dns.so.*
endif

ifeq ($(BR2_INSTALL_LIBSTDCPP),y)
TOOLCHAIN_NATIVE_LIBS += libstdc++.so.*
endif

TOOLCHAIN_NATIVE_LIBS += $(call qstrip,$(BR2_TOOLCHAIN_EXTRA_NATIVE_LIBS))

# Details about sysroot directory selection.
#
# To find the sysroot directory, we use the trick of looking for the
# 'libc.a' file with the -print-file-name gcc option, and then
# mangling the path to find the base directory of the sysroot.
#
# Note that we do not use the -print-sysroot option, because it is
# only available since gcc 4.4.x, and we only recently dropped support
# for 4.2.x and 4.3.x.
#
# When doing this, we don't pass any option to gcc that could select a
# multilib variant (such as -march) as we want the "main" sysroot,
# which contains all variants of the C library in the case of multilib
# toolchains. We use the TARGET_CC_NO_SYSROOT variable, which is the
# path of the cross-compiler, without the --sysroot=$(STAGING_DIR),
# since what we want to find is the location of the original toolchain
# sysroot. This "main" sysroot directory is stored in SYSROOT_DIR.
#
# Then, multilib toolchains are a little bit more complicated, since
# they in fact have multiple sysroots, one for each variant supported
# by the toolchain. So we need to find the particular sysroot we're
# interested in.
#
# To do so, we ask the compiler where its sysroot is by passing all
# flags (including -march and al.), except the --sysroot flag since we
# want to the compiler to tell us where its original sysroot
# is. ARCH_SUBDIR will contain the subdirectory, in the main
# SYSROOT_DIR, that corresponds to the selected architecture
# variant. ARCH_SYSROOT_DIR will contain the full path to this
# location.
#
# One might wonder why we don't just bother with ARCH_SYSROOT_DIR. The
# fact is that in multilib toolchains, the header files are often only
# present in the main sysroot, and only the libraries are available in
# each variant-specific sysroot directory.

TOOLCHAIN_NATIVE_PREFIX = $(call qstrip,$(BR2_TOOLCHAIN_NATIVE_PREFIX))

#TOOLCHAIN_NATIVE_BIN := $(shell dirname $(shell which $(BR2_TOOLCHAIN_EXTERNAL_PREFIX)-gcc))
TOOLCHAIN_NATIVE_BIN := /usr/bin

# If this is a buildroot toolchain, it already has a wrapper which we want to
# bypass. Since this is only evaluated after it has been extracted, we can use
# $(wildcard ...) here.
TOOLCHAIN_NATIVE_SUFFIX = \
	$(if $(wildcard $(TOOLCHAIN_NATIVE_BIN)/*.br_real),.br_real)
TOOLCHAIN_NATIVE_TOOLCHAIN_WRAPPER_ARGS += \
	-DBR_CROSS_PATH_SUFFIX='"$(TOOLCHAIN_NATIVE_SUFFIX)"'

TOOLCHAIN_NATIVE_CROSS = $(TOOLCHAIN_NATIVE_BIN)/
TOOLCHAIN_NATIVE_CC = gcc
TOOLCHAIN_NATIVE_CXX = g++
TOOLCHAIN_NATIVE_READELF = readelf

ifeq ($(filter $(HOST_DIR)/%,$(TOOLCHAIN_NATIVE_BIN)),)
# TOOLCHAIN_NATIVE_BIN points outside HOST_DIR => absolute path
TOOLCHAIN_NATIVE_TOOLCHAIN_WRAPPER_ARGS += \
	-DBR_CROSS_PATH_ABS='"$(TOOLCHAIN_NATIVE_BIN)"'
else
# TOOLCHAIN_NATIVE_BIN points inside HOST_DIR => relative path
TOOLCHAIN_NATIVE_TOOLCHAIN_WRAPPER_ARGS += \
	-DBR_CROSS_PATH_REL='"$(TOOLCHAIN_NATIVE_BIN:$(HOST_DIR)/%=%)"'
endif

# In fact, we don't need to download the toolchain, since it is already
# available on the system, so force the site and source to be empty so
# that nothing will be downloaded/extracted.
TOOLCHAIN_NATIVE_SITE =
TOOLCHAIN_NATIVE_SOURCE =

TOOLCHAIN_NATIVE_ADD_TOOLCHAIN_DEPENDENCY = NO

TOOLCHAIN_NATIVE_INSTALL_STAGING = YES

# Returns the location of the libc.so.6.1 file for the given compiler + flags
define toolchain_find_libc_so
$$(readlink -f $$(LANG=C $(1) -print-file-name=libc.so.6.1))
endef

# Returns the sysroot location for the given compiler + flags. We need
# to handle cases where libc.so.6.1 is in:
#
#  - lib/
#  - usr/lib/
#  - lib32/
#  - lib64/
#  - lib32-fp/ (Cavium toolchain)
#  - lib64-fp/ (Cavium toolchain)
#  - usr/lib/<tuple>/ (Linaro toolchain)
#
# And variations on these.
define toolchain_find_sysroot
$$(printf $(call toolchain_find_libc_so,$(1)) | sed -r -e 's:(usr/)?lib(32|64)?([^/]*)?/([^/]*/)?libc\.a::')
endef

# Returns the lib subdirectory for the given compiler + flags (i.e
# typically lib32 or lib64 for some toolchains)
define toolchain_find_libdir
$$(printf $(call toolchain_find_libc_so,$(1)) | sed -r -e 's:.*/(usr/)?(lib(32|64)?([^/]*)?)/([^/]*/)?libc.a:\2:')
endef

# Checks for an already installed toolchain: check the toolchain
# location, check that it is usable, and then verify that it
# matches the configuration provided in Buildroot: ABI, C++ support,
# kernel headers version, type of C library and all C library features.
define TOOLCHAIN_NATIVE_CONFIGURE_CMDS
	$(Q)$(call check_cross_compiler_exists,$(TOOLCHAIN_NATIVE_CC))
	$(Q)$(call check_unusable_toolchain,$(TOOLCHAIN_NATIVE_CC))
	$(Q)SYSROOT_DIR="$(call toolchain_find_sysroot,$(TOOLCHAIN_NATIVE_CC))" ; \
	$(call check_kernel_headers_version,\
		$(call toolchain_find_sysroot,$(TOOLCHAIN_NATIVE_CC)),\
		$(call qstrip,$(BR2_TOOLCHAIN_HEADERS_AT_LEAST))); \
	$(call check_gcc_version,$(TOOLCHAIN_NATIVE_CC),\
		$(call qstrip,$(BR2_TOOLCHAIN_GCC_AT_LEAST))); \
	if test "$(BR2_INSTALL_LIBSTDCPP)" = "y" ; then \
		$(call check_cplusplus,$(TOOLCHAIN_NATIVE_CXX)) ; \
	fi 
endef

# Create a symlink from (usr/)$(ARCH_LIB_DIR) to lib.
# Note: the skeleton package additionally creates lib32->lib or lib64->lib
# (as appropriate)
#
# $1: destination directory (TARGET_DIR / STAGING_DIR)
create_lib_symlinks = \
       $(Q)DESTDIR="$(strip $1)" ; \
       ARCH_LIB_DIR="$(call toolchain_find_libdir,$(TOOLCHAIN_NATIVE_CC) $(TOOLCHAIN_NATIVE_CFLAGS))" ; \
       if [ ! -e "$${DESTDIR}/$${ARCH_LIB_DIR}" ]; then \
               ln -snf lib "$${DESTDIR}/$${ARCH_LIB_DIR}" ; \
       fi

define TOOLCHAIN_NATIVE_CREATE_STAGING_LIB_SYMLINK
       $(call create_lib_symlinks,$(STAGING_DIR))
endef

define TOOLCHAIN_NATIVE_CREATE_TARGET_LIB_SYMLINK
       $(call create_lib_symlinks,$(TARGET_DIR))
endef

# Integration of the toolchain into Buildroot: find the main sysroot
# and the variant-specific sysroot, then copy the needed libraries to
# the $(TARGET_DIR) and copy the whole sysroot (libraries and headers)
# to $(STAGING_DIR).
#
# Variables are defined as follows:
#
#  LIBC_A_LOCATION:     location of the libc.a file in the default
#                       multilib variant (allows to find the main
#                       sysroot directory)
#                       Ex: /x-tools/mips-2011.03/mips-linux-gnu/libc/usr/lib/libc.a
#
#  SYSROOT_DIR:         the main sysroot directory, deduced from
#                       LIBC_A_LOCATION by removing the
#                       usr/lib[32|64]/libc.a part of the path.
#                       Ex: /x-tools/mips-2011.03/mips-linux-gnu/libc/
#
# ARCH_LIBC_A_LOCATION: location of the libc.a file in the selected
#                       multilib variant (taking into account the
#                       CFLAGS). Allows to find the sysroot of the
#                       selected multilib variant.
#                       Ex: /x-tools/mips-2011.03/mips-linux-gnu/libc/mips16/soft-float/el/usr/lib/libc.a
#
# ARCH_SYSROOT_DIR:     the sysroot of the selected multilib variant,
#                       deduced from ARCH_LIBC_A_LOCATION by removing
#                       usr/lib[32|64]/libc.a at the end of the path.
#                       Ex: /x-tools/mips-2011.03/mips-linux-gnu/libc/mips16/soft-float/el/
#
# ARCH_LIB_DIR:         'lib', 'lib32' or 'lib64' depending on where libraries
#                       are stored. Deduced from ARCH_LIBC_A_LOCATION by
#                       looking at usr/lib??/libc.a.
#                       Ex: lib
#
# ARCH_SUBDIR:          the relative location of the sysroot of the selected
#                       multilib variant compared to the main sysroot.
#			Ex: mips16/soft-float/el
#
# SUPPORT_LIB_DIR:      some toolchains, such as recent Linaro toolchains,
#                       store GCC support libraries (libstdc++,
#                       libgcc_s, etc.) outside of the sysroot. In
#                       this case, SUPPORT_LIB_DIR is set to a
#                       non-empty value, and points to the directory
#                       where these support libraries are
#                       available. Those libraries will be copied to
#                       our sysroot, and the directory will also be
#                       considered when searching libraries for copy
#                       to the target filesystem.
#
# Please be very careful to check the major toolchain sources:
# Buildroot, Crosstool-NG, CodeSourcery and Linaro
# before doing any modification on the below logic.

ifeq ($(BR2_STATIC_LIBS),)
define TOOLCHAIN_NATIVE_INSTALL_TARGET_LIBS
	$(Q)$(call MESSAGE,"Copying native toolchain libraries to target...")
	$(Q)for libs in $(TOOLCHAIN_NATIVE_LIBS); do \
		$(call copy_toolchain_lib_root,$$libs); \
	done
endef
endif

ifeq ($(BR2_TOOLCHAIN_NATIVE_GDB_SERVER_COPY),y)
define TOOLCHAIN_NATIVE_INSTALL_TARGET_GDBSERVER
	$(Q)$(call MESSAGE,"Copying gdbserver")
	$(Q)ARCH_SYSROOT_DIR="$(call toolchain_find_sysroot,$(TOOLCHAIN_NATIVE_CC) $(TOOLCHAIN_NATIVE_CFLAGS))" ; \
	ARCH_LIB_DIR="$(call toolchain_find_libdir,$(TOOLCHAIN_NATIVE_CC) $(TOOLCHAIN_NATIVE_CFLAGS))" ; \
	gdbserver_found=0 ; \
	for d in $${ARCH_SYSROOT_DIR}/usr \
		 $${ARCH_SYSROOT_DIR}/../debug-root/usr \
		 $${ARCH_SYSROOT_DIR}/usr/$${ARCH_LIB_DIR} \
		 $(TOOLCHAIN_NATIVE_INSTALL_DIR); do \
		if test -f $${d}/bin/gdbserver ; then \
			install -m 0755 -D $${d}/bin/gdbserver $(TARGET_DIR)/usr/bin/gdbserver ; \
			gdbserver_found=1 ; \
			break ; \
		fi ; \
	done ; \
	if [ $${gdbserver_found} -eq 0 ] ; then \
		echo "Could not find gdbserver in native toolchain" ; \
		exit 1 ; \
	fi
endef
endif

define TOOLCHAIN_NATIVE_INSTALL_SYSROOT_LIBS
	$(Q)SYSROOT_DIR="$(call toolchain_find_sysroot,$(TOOLCHAIN_NATIVE_CC))" ; \
	ARCH_SYSROOT_DIR="$(call toolchain_find_sysroot,$(TOOLCHAIN_NATIVE_CC) $(TOOLCHAIN_NATIVE_CFLAGS))" ; \
	ARCH_LIB_DIR="$(call toolchain_find_libdir,$(TOOLCHAIN_NATIVE_CC) $(TOOLCHAIN_NATIVE_CFLAGS))" ; \
	SUPPORT_LIB_DIR="" ; \
	if test `find $${ARCH_SYSROOT_DIR} -name 'libstdc++.a' | wc -l` -eq 0 ; then \
		LIBSTDCPP_A_LOCATION=$$(LANG=C $(TOOLCHAIN_NATIVE_CC) $(TOOLCHAIN_NATIVE_CFLAGS) -print-file-name=libstdc++.a) ; \
		if [ -e "$${LIBSTDCPP_A_LOCATION}" ]; then \
			SUPPORT_LIB_DIR=`readlink -f $${LIBSTDCPP_A_LOCATION} | sed -r -e 's:libstdc\+\+\.a::'` ; \
		fi ; \
	fi ; \
	ARCH_SUBDIR=`echo $${ARCH_SYSROOT_DIR} | sed -r -e "s:^$${SYSROOT_DIR}(.*)/$$:\1:"` ; \
	$(call MESSAGE,"Copying native toolchain sysroot to staging...") ; \
	$(call copy_toolchain_sysroot,$${SYSROOT_DIR},$${ARCH_SYSROOT_DIR},$${ARCH_SUBDIR},$${ARCH_LIB_DIR},$${SUPPORT_LIB_DIR})
endef

# Build toolchain wrapper for preprocessor, C and C++ compiler and setup
# symlinks for everything else. Skip gdb symlink when we are building our
# own gdb to prevent two gdb's in output/host/usr/bin.
# The LTO support in gcc creates wrappers for ar, ranlib and nm which load
# the lto plugin. These wrappers are called *-gcc-ar, *-gcc-ranlib, and
# *-gcc-nm and should be used instead of the real programs when -flto is
# used. However, we should not add the toolchain wrapper for them, and they
# match the *cc-* pattern. Therefore, an additional case is added for *-ar,
# *-ranlib and *-nm.
define TOOLCHAIN_NATIVE_INSTALL_WRAPPER
	$(Q)cd $(HOST_DIR)/usr/bin; \
	for i in $(TOOLCHAIN_NATIVE_CROSS)*; do \
		base=$${i##*/}; \
		case "$$base" in \
		*-ar|*-ranlib|*-nm) \
			ln -sf $$(echo $$i | sed 's%^$(HOST_DIR)%../..%') .; \
			;; \
		*cc|*cc-*|*++|*++-*|*cpp) \
			ln -sf toolchain-wrapper $$base; \
			;; \
		*gdb|*gdbtui) \
			if test "$(BR2_PACKAGE_HOST_GDB)" != "y"; then \
				ln -sf $$(echo $$i | sed 's%^$(HOST_DIR)%../..%') .; \
			fi \
			;; \
		*) \
			ln -sf $$(echo $$i | sed 's%^$(HOST_DIR)%../..%') .; \
			;; \
		esac; \
	done
endef

#
# Generate gdbinit file for use with Buildroot
#
define TOOLCHAIN_NATIVE_INSTALL_GDBINIT
	$(Q)if test -f $(TARGET_CROSS)gdb ; then \
		$(call MESSAGE,"Installing gdbinit"); \
		$(gen_gdbinit_file); \
	fi
endef

#TOOLCHAIN_NATIVE_BUILD_CMDS = $(TOOLCHAIN_BUILD_WRAPPER)

define TOOLCHAIN_NATIVE_INSTALL_STAGING_CMDS
	$(TOOLCHAIN_NATIVE_CREATE_STAGING_LIB_SYMLINK)
	$(TOOLCHAIN_NATIVE_INSTALL_SYSROOT_LIBS)
	$(TOOLCHAIN_NATIVE_INSTALL_GDBINIT)
endef

# Even though we're installing things in both the staging, the host
# and the target directory, we do everything within the
# install-staging step, arbitrarily.
define TOOLCHAIN_NATIVE_INSTALL_TARGET_CMDS
	$(TOOLCHAIN_NATIVE_CREATE_TARGET_LIB_SYMLINK)
	$(TOOLCHAIN_NATIVE_INSTALL_TARGET_LIBS)
	$(TOOLCHAIN_NATIVE_INSTALL_TARGET_GDBSERVER)
endef

$(eval $(generic-package))

