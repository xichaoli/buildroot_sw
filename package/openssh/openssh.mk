################################################################################
#
# openssh
#
################################################################################

OPENSSH_VERSION = 7.6p1
OPENSSH_SITE = http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable
OPENSSH_LICENSE = BSD-3-Clause, BSD-2-Clause, Public Domain
OPENSSH_LICENSE_FILES = LICENCE
# Autoreconf needed due to the following patches modifying configure.ac:
# 0001-configure-ac-detect-mips-abi.patch
# 0002-configure-ac-properly-set-seccomp-audit-arch-for-mips64.patch
OPENSSH_AUTORECONF = YES
OPENSSH_CONF_ENV = LD="$(TARGET_CC)" LDFLAGS="$(TARGET_CFLAGS)"
OPENSSH_CONF_OPTS = \
	--sysconfdir=/etc/ssh \
	--disable-lastlog \
	--disable-utmp \
	--disable-utmpx \
	--disable-wtmp \
	--disable-wtmpx \
	--disable-strip \
	--cache-file=config_cache

define OPENSSH_USERS
	sshd -1 sshd -1 * - - - SSH drop priv user
endef

define OPENSSH_INSTALL_UNSAFE_CONF
	sed -i '/^#PermitRootLogin/a PermitRootLogin yes' $(TARGET_DIR)/etc/ssh/sshd_config
	sed -i '/^#PasswordAuthentication/a PasswordAuthentication yes' $(TARGET_DIR)/etc/ssh/sshd_config
endef

BR2_PACKAGE_OPENSSH_CLIENT_ALIVE_INTERVAL = $(shell expr $(call qstrip,$(BR2_PACKAGE_OPENSSH_SESSION_MAINTENANCE_TIME)) / 3)

define OPENSSH_CUSTOM_CONF
	cp -a $(@D)/sshd_config $(TARGET_DIR)/etc/ssh/sshd_config
	sed -i '/^#Port/c Port $(call qstrip,$(BR2_PACKAGE_OPENSSH_LISTEN_PORT))' $(TARGET_DIR)/etc/ssh/sshd_config
	sed -i "1,/^#ListenAddress/{s:^#ListenAddress.*$$:ListenAddress $(call qstrip,$(BR2_PACKAGE_OPENSSH_LISTEN_ADDRESS)):}" $(TARGET_DIR)/etc/ssh/sshd_config
	sed -i '/^#LoginGraceTime/c LoginGraceTime $(call qstrip,$(BR2_PACKAGE_OPENSSH_LOGIN_GRACE_TIME))' $(TARGET_DIR)/etc/ssh/sshd_config
	sed -i "/^#ClientAliveInterval/{s:^#ClientAliveInterval.*$$:ClientAliveInterval $(BR2_PACKAGE_OPENSSH_CLIENT_ALIVE_INTERVAL):}" $(TARGET_DIR)/etc/ssh/sshd_config
	sed -i '/^#PermitRootLogin/c PermitRootLogin $(call qstrip,$(BR2_PACKAGE_OPENSSH_PERMIT_ROOT_LOGIN))' $(TARGET_DIR)/etc/ssh/sshd_config
	sed -i '/^#PasswordAuthentication/c PasswordAuthentication $(call qstrip,$(BR2_PACKAGE_OPENSSH_PASSWORD_AUTH))' $(TARGET_DIR)/etc/ssh/sshd_config
	sed -i '/^#MaxAuthTries/c MaxAuthTries $(call qstrip,$(BR2_PACKAGE_OPENSSH_MAX_AUTH_TRIES))' $(TARGET_DIR)/etc/ssh/sshd_config
	sed -i '/^#MaxSessions/c MaxSessions $(call qstrip,$(BR2_PACKAGE_OPENSSH_MAX_SESSIONS))' $(TARGET_DIR)/etc/ssh/sshd_config
	if [ -n $(BR2_PACKAGE_OPENSSH_DENY_USERS) ];then \
		sed -i  '$$ a DenyUsers $(BR2_PACKAGE_OPENSSH_DENY_USERS)' $(TARGET_DIR)/etc/ssh/sshd_config;\
	fi
	if [ -n $(BR2_PACKAGE_OPENSSH_ALLOW_USERS) ];then \
		sed -i  '$$ a AllowUsers $(BR2_PACKAGE_OPENSSH_ALLOW_USERS)' $(TARGET_DIR)/etc/ssh/sshd_config; \
	fi
endef

ifeq ($(BR2_PACKAGE_OPENSSH_UNSAFE_CONF),y)
OPENSSH_POST_INSTALL_TARGET_HOOKS += OPENSSH_INSTALL_UNSAFE_CONF
else
OPENSSH_POST_INSTALL_TARGET_HOOKS += OPENSSH_CUSTOM_CONF
endif

ifeq ($(BR2_TOOLCHAIN_SUPPORTS_PIE),)
OPENSSH_CONF_OPTS += --without-pie
endif

OPENSSH_DEPENDENCIES = zlib openssl

OPENSSH_CONF_OPTS += --with-ssl-dir=${STAGING_DIR}/usr --without-openssl-header-check

ifeq ($(BR2_PACKAGE_CRYPTODEV_LINUX),y)
OPENSSH_DEPENDENCIES += cryptodev-linux
OPENSSH_CONF_OPTS += --with-ssl-engine
else
OPENSSH_CONF_OPTS += --without-ssl-engine
endif

ifeq ($(BR2_PACKAGE_LINUX_PAM),y)
define OPENSSH_INSTALL_PAM_CONF
	$(INSTALL) -D -m 644 $(@D)/contrib/sshd.pam.generic $(TARGET_DIR)/etc/pam.d/sshd
	$(SED) '\%password   required     /lib/security/pam_cracklib.so%d' $(TARGET_DIR)/etc/pam.d/sshd
	$(SED) 's/\#UsePAM no/UsePAM yes/' $(TARGET_DIR)/etc/ssh/sshd_config
endef

OPENSSH_DEPENDENCIES += linux-pam
OPENSSH_CONF_OPTS += --with-pam
OPENSSH_POST_INSTALL_TARGET_HOOKS += OPENSSH_INSTALL_PAM_CONF
else
OPENSSH_CONF_OPTS += --without-pam
endif

ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
OPENSSH_DEPENDENCIES += libselinux
OPENSSH_CONF_OPTS += --with-selinux
else
OPENSSH_CONF_OPTS += --without-selinux
endif

define OPENSSH_INSTALL_COPY_ID
	$(INSTALL) -D -m 755 $(@D)/contrib/ssh-copy-id $(TARGET_DIR)/usr/bin/ssh-copy-id
endef
OPENSSH_POST_INSTALL_TARGET_HOOKS += OPENSSH_INSTALL_COPY_ID

define OPENSSH_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/openssh/sshd.service \
		$(TARGET_DIR)/usr/lib/systemd/system/sshd.service
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -fs ../../../../usr/lib/systemd/system/sshd.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/sshd.service
endef

define OPENSSH_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 755 package/openssh/S50sshd \
		$(TARGET_DIR)/etc/init.d/S50sshd
endef

define OPENSSH_INSTALL_SSH_COPY_ID
	$(INSTALL) -D -m 755 $(@D)/contrib/ssh-copy-id $(TARGET_DIR)/usr/bin/ssh-copy-id
endef

OPENSSH_POST_INSTALL_TARGET_HOOKS += OPENSSH_INSTALL_SSH_COPY_ID

$(eval $(autotools-package))
