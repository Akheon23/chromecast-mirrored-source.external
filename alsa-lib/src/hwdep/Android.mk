LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := \
	hwdep.c \
	hwdep_hw.c \
	hwdep_symbols.c
LOCAL_CFLAGS := $(ALSA_LIB_CFLAGS)
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../include
LOCAL_MODULE := libhwdep
include $(BUILD_STATIC_LIBRARY)
