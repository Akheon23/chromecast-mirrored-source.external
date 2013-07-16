LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := \
	rawmidi.c \
	rawmidi_hw.c \
	rawmidi_symbols.c \
	rawmidi_virt.c
LOCAL_CFLAGS := $(ALSA_LIB_CFLAGS)
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../include
LOCAL_MODULE := librawmidi
include $(BUILD_STATIC_LIBRARY)
