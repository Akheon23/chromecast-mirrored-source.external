# Copyright 2013 Google Inc.  All Rights Reserved.

LOCAL_PATH:= $(call my-dir)

# Source
NSS_SRC_TAR_GZ := $(LOCAL_PATH)/nss-3.15.3-with-nspr-4.10.2.tar.gz

# Top level path after untar
NSS_TOP_DIR:= nss-3.15.3

# Local command to build NSS+NSPR
NSS_BUILD_CMD := $(LOCAL_PATH)/build.sh

# Fake target so we only build once
NSS_BUILD_COMPLETE:= nss-build-complete.txt

# Pick up CFLAGS and pass them to build script
TARGET_CFLAGS := $(TARGET_GLOBAL_CFLAGS)

ifeq ($(TARGET_ARCH),arm)
# Add arm (v.s. thumb) CFLAGS
TARGET_CFLAGS += $(TARGET_arm_CFLAGS)
endif

include $(CLEAR_VARS)
LOCAL_MODULE := nss
LOCAL_MODULE_TAGS := optional
# NSS needs libz and possibly other bits from build_sysroot,
# so we need to depend on toolchain-libs.
# Content_shell needs to add nss as dependency if it wants to use NSS.
LOCAL_REQUIRED_MODULES := toolchain-libs
include $(BUILD_PHONY_PACKAGE)

$(LOCAL_BUILT_MODULE): $(TARGET_OUT_INTERMEDIATES)/$(NSS_BUILD_COMPLETE)

$(TARGET_OUT_INTERMEDIATES)/$(NSS_BUILD_COMPLETE): $(NSS_SRC_TAR_GZ) $(NSS_BUILD_CMD) \
	| toolchain-libs
	TARGET_CC="$(TARGET_CC)" TARGET_CFLAGS="$(TARGET_CFLAGS)" \
	TARGET_AR="$(TARGET_AR)" \
	TARGET_OUT="$(TARGET_OUT)/.." TARGET_ARCH="$(TARGET_ARCH)" \
	HOST_OUT="$(HOST_OUT)" NSS_SRC_TAR_GZ="$(NSS_SRC_TAR_GZ)" \
	NSS_TOP_DIR="$(NSS_TOP_DIR)" CURDIR="$(CURDIR)" \
	$(NSS_BUILD_CMD)
	touch $@
