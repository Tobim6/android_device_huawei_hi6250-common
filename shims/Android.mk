LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := libfence_compat
LOCAL_SRC_FILES := fence_compat.c
LOCAL_SHARED_LIBRARIES := libc
LOCAL_VENDOR_MODULE := true
LOCAL_MODULE_TAGS := optional
LOCAL_MULTILIB := both
include $(BUILD_SHARED_LIBRARY)

# The ISP dts image (157 MB) lives in /system/etc/firmware (it does not fit in /vendor); the kernel
# only searches /system/vendor/firmware, so link it from there.
ISP_DTS_LINK := $(TARGET_OUT_VENDOR)/firmware/isp_dts.img
$(ISP_DTS_LINK): $(LOCAL_PATH)/Android.mk
	@echo "Symlink: $@ -> /system/etc/firmware/isp_dts.img"
	@mkdir -p $(dir $@)
	@rm -f $@
	$(hide) ln -sf /system/etc/firmware/isp_dts.img $@
ALL_DEFAULT_INSTALLED_MODULES += $(ISP_DTS_LINK)
