# this is now the default FreeType build for Android
#
ifndef USE_FREETYPE
USE_FREETYPE := 2.4.2
endif

ifeq ($(USE_FREETYPE),2.4.2)
LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

# compile in ARM mode, since the glyph loader/renderer is a hotspot
# when loading complex pages in the browser
#
LOCAL_ARM_MODE := arm

LOCAL_SRC_FILES:= \
	src/base/ftbbox.c \
	src/base/ftbitmap.c \
	src/base/ftfstype.c \
	src/base/ftglyph.c \
	src/base/ftlcdfil.c \
	src/base/ftstroke.c \
	src/base/ftsynth.c \
	src/base/fttype1.c \
	src/base/ftxf86.c \
	src/base/ftbase.c \
	src/base/ftsystem.c \
	src/base/ftinit.c \
	src/base/ftgasp.c \
	src/raster/raster.c \
	src/sfnt/sfnt.c \
	src/smooth/smooth.c \
	src/autofit/autofit.c \
	src/truetype/truetype.c \
	src/cff/cff.c \
	src/psnames/psnames.c \
	src/pshinter/pshinter.c

LOCAL_C_INCLUDES += \
	$(LOCAL_PATH)/builds \
	$(LOCAL_PATH)/include

LOCAL_CFLAGS += -W -Wall
LOCAL_CFLAGS += -fPIC -DPIC
LOCAL_CFLAGS += "-DDARWIN_NO_CARBON"
LOCAL_CFLAGS += "-DFT2_BUILD_LIBRARY"

# the following is for testing only, and should not be used in final builds
# of the product
#LOCAL_CFLAGS += "-DTT_CONFIG_OPTION_BYTECODE_INTERPRETER"

LOCAL_CFLAGS += -O2

LOCAL_MODULE:= libfreetype

ifeq ($(BUILD_EUREKA),true)
LOCAL_TOOLCHAIN_PREBUILTS := \
	$(LOCAL_PATH)/include/ft2build.h:usr/include/ft2build.h \
	$(LOCAL_PATH)/include/freetype/config/ftheader.h:usr/include/freetype2/freetype/config/ftheader.h \
	$(LOCAL_PATH)/include/freetype/config/ftconfig.h:usr/include/freetype2/freetype/config/ftconfig.h \
	$(LOCAL_PATH)/include/freetype/config/ftoption.h:usr/include/freetype2/freetype/config/ftoption.h \
	$(LOCAL_PATH)/include/freetype/config/ftstdlib.h:usr/include/freetype2/freetype/config/ftstdlib.h \
	$(LOCAL_PATH)/include/freetype/freetype.h:usr/include/freetype2/freetype/freetype.h \
	$(LOCAL_PATH)/include/freetype/ftadvanc.h:usr/include/freetype2/freetype/ftadvanc.h \
	$(LOCAL_PATH)/include/freetype/ftbitmap.h:usr/include/freetype2/freetype/ftbitmap.h \
	$(LOCAL_PATH)/include/freetype/fterrdef.h:usr/include/freetype2/freetype/fterrdef.h \
	$(LOCAL_PATH)/include/freetype/fterrors.h:usr/include/freetype2/freetype/fterrors.h \
	$(LOCAL_PATH)/include/freetype/ftglyph.h:usr/include/freetype2/freetype/ftglyph.h \
	$(LOCAL_PATH)/include/freetype/ftimage.h:usr/include/freetype2/freetype/ftimage.h \
	$(LOCAL_PATH)/include/freetype/ftlcdfil.h:usr/include/freetype2/freetype/ftlcdfil.h \
	$(LOCAL_PATH)/include/freetype/ftmodapi.h:usr/include/freetype2/freetype/ftmodapi.h \
	$(LOCAL_PATH)/include/freetype/ftmoderr.h:usr/include/freetype2/freetype/ftmoderr.h \
	$(LOCAL_PATH)/include/freetype/ftoutln.h:usr/include/freetype2/freetype/ftoutln.h \
	$(LOCAL_PATH)/include/freetype/ftsizes.h:usr/include/freetype2/freetype/ftsizes.h \
	$(LOCAL_PATH)/include/freetype/ftsnames.h:usr/include/freetype2/freetype/ftsnames.h \
	$(LOCAL_PATH)/include/freetype/ftsynth.h:usr/include/freetype2/freetype/ftsynth.h \
	$(LOCAL_PATH)/include/freetype/ftsystem.h:usr/include/freetype2/freetype/ftsystem.h \
	$(LOCAL_PATH)/include/freetype/fttypes.h:usr/include/freetype2/freetype/fttypes.h \
	$(LOCAL_PATH)/include/freetype/ftxf86.h:usr/include/freetype2/freetype/ftxf86.h \
	$(LOCAL_PATH)/include/freetype/t1tables.h:usr/include/freetype2/freetype/t1tables.h \
	$(LOCAL_PATH)/include/freetype/ttnameid.h:usr/include/freetype2/freetype/ttnameid.h \
	$(LOCAL_PATH)/include/freetype/tttables.h:usr/include/freetype2/freetype/tttables.h
endif

include $(BUILD_SHARED_LIBRARY)
endif
