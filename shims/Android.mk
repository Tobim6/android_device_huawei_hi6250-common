LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := libfence_compat
LOCAL_SRC_FILES := fence_compat.c
LOCAL_SHARED_LIBRARIES := libc
LOCAL_VENDOR_MODULE := true
LOCAL_MODULE_TAGS := optional
LOCAL_MULTILIB := both
include $(BUILD_SHARED_LIBRARY)
