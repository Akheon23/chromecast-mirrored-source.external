LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := \
	timer.c \
	timer_hw.c \
	timer_query.c \
	timer_query_hw.c \
	timer_symbols.c
LOCAL_CFLAGS := $(ALSA_LIB_CFLAGS)
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../include
LOCAL_MODULE := libtimer
include $(BUILD_STATIC_LIBRARY)
