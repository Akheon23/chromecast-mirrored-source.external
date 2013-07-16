LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := \
	atomic.c \
	interval.c \
	mask.c \
	pcm_adpcm.c \
	pcm_alaw.c \
	pcm_asym.c \
	pcm.c \
	pcm_copy.c \
	pcm_direct.c \
	pcm_dmix.c \
	pcm_dshare.c \
	pcm_dsnoop.c \
	pcm_empty.c \
	pcm_extplug.c \
	pcm_file.c \
	pcm_generic.c \
	pcm_hooks.c \
	pcm_hw.c \
	pcm_iec958.c \
	pcm_ioplug.c \
	pcm_ladspa.c \
	pcm_lfloat.c \
	pcm_linear.c \
	pcm_meter.c \
	pcm_misc.c \
	pcm_mmap.c \
	pcm_mmap_emul.c \
	pcm_mulaw.c \
	pcm_multi.c \
	pcm_null.c \
	pcm_params.c \
	pcm_plug.c \
	pcm_plugin.c \
	pcm_rate.c \
	pcm_rate_linear.c \
	pcm_route.c \
	pcm_share.c \
	pcm_shm.c \
	pcm_simple.c \
	pcm_softvol.c \
	pcm_symbols.c
LOCAL_CFLAGS := $(ALSA_LIB_CFLAGS)
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../include
LOCAL_MODULE := libpcm
include $(BUILD_STATIC_LIBRARY)
