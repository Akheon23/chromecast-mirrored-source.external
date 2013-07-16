LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := \
	seq.c \
	seq_event.c \
	seq_hw.c \
	seqmid.c \
	seq_midi_event.c \
	seq_old.c \
	seq_symbols.c
LOCAL_CFLAGS := $(ALSA_LIB_CFLAGS)
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../include
LOCAL_MODULE := libseq
include $(BUILD_STATIC_LIBRARY)
