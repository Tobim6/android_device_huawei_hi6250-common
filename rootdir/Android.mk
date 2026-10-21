LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE       := init.hi6250.rc
LOCAL_MODULE_TAGS  := optional eng
LOCAL_MODULE_CLASS := ETC
LOCAL_PROPRIETARY_MODULE := true
LOCAL_SRC_FILES    := etc/init.hi6250.rc
# system/core/rootdir/init.rc only ever imports this file from
# "/init.${ro.hardware}.rc" (ramdisk root) or
# "/vendor/etc/init/hw/init.${ro.hardware}.rc" (Treble vendor path). This was
# installing to $(TARGET_OUT_ETC)/init, i.e. /system/etc/init/init.hi6250.rc
# -- a path neither import line ever checks, so this entire file (including
# "on post-fs-data: start teecd" and the sdcardfs extension mkdirs) has never
# actually been parsed by init on any device using this tree.
LOCAL_MODULE_PATH  := $(TARGET_OUT_VENDOR_ETC)/init/hw
include $(BUILD_PREBUILT)
