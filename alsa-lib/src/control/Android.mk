LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := \
	cards.c \
	control.c \
	control_ext.c \
	control_hw.c \
	control_shm.c \
	control_symbols.c \
	ctlparse.c \
	hcontrol.c \
	namehint.c \
	setup.c \
	tlv.c
LOCAL_CFLAGS := $(ALSA_LIB_CFLAGS)
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../include
LOCAL_MODULE := libcontrol
include $(BUILD_STATIC_LIBRARY)
