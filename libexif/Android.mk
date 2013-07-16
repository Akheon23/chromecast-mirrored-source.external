LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LIBEXIF_SRC_FILES :=\
	canon/exif-mnote-data-canon.c \
	canon/mnote-canon-entry.c \
	canon/mnote-canon-tag.c \
	exif-byte-order.c \
	exif-content.c \
	exif-data.c \
	exif-entry.c \
	exif-format.c \
	exif-ifd.c \
	exif-loader.c \
	exif-log.c \
	exif-mem.c \
	exif-mnote-data.c \
	exif-tag.c \
	exif-utils.c \
	fuji/exif-mnote-data-fuji.c \
	fuji/mnote-fuji-entry.c \
	fuji/mnote-fuji-tag.c \
	olympus/exif-mnote-data-olympus.c \
	olympus/mnote-olympus-entry.c \
	olympus/mnote-olympus-tag.c \
	pentax/exif-mnote-data-pentax.c \
	pentax/mnote-pentax-entry.c \
	pentax/mnote-pentax-tag.c
LOCAL_SRC_FILES := $(addprefix libexif/, $(LIBEXIF_SRC_FILES))
LOCAL_CFLAGS := -DHAVE_CONFIG_H -DGETTEXT_PACKAGE=\"libexif-12\" \
	-DLOCALEDIR=\"/usr/local/share/locale\"
LOCAL_C_INCLUDES := $(LOCAL_PATH)/include
LOCAL_MODULE := libexif
LOCAL_MODULE_TAGS := optional
include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)
SSL_CERTS_PATH := $(LOCAL_PATH)
LOCAL_MODULE := libexif_symlink
LOCAL_MODULE_TAGS := optional
LOCAL_REQUIRED_MODULES := libexif
include $(BUILD_PHONY_PACKAGE)

.PHONY: create_libexif_symlink
create_libexif_symlink: libexif
	ln -snf libexif.so $(TARGET_OUT_SHARED_LIBRARIES)/libexif.so.12

$(LOCAL_BUILT_MODULE): create_libexif_symlink
