LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := \
	bag.c \
	mixer.c \
	simple_abst.c \
	simple.c \
	simple_none.c
LOCAL_CFLAGS := $(ALSA_LIB_CFLAGS)
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../include
LOCAL_MODULE := libmixer
include $(BUILD_STATIC_LIBRARY)
