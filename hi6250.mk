#
# Copyright (C) 2018 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

$(call inherit-product, vendor/huawei/hi6250-common/hi6250-common-vendor.mk)

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay \
    $(LOCAL_PATH)/overlay-lineage

# Properties
-include $(LOCAL_PATH)/system_prop.mk

# Audio
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio/audio_policy_configuration.xml:system/etc/audio_policy_configuration.xml

# bfm
PRODUCT_PACKAGES += \
    bfm-ctl

# Camera (the ICameraProvider is registered by the vendor CameraDaemon itself)
PRODUCT_PACKAGES += \
    Snap

# Device init scripts
PRODUCT_PACKAGES += \
    init.hi6250.rc

# Display
PRODUCT_PACKAGES += \
    libion

# Gps
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/gps/gps.conf:system/etc/gps.conf

# Input
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/keylayout/fingerprint.kl:system/usr/keylayout/fingerprint.kl

# LineageHw
PRODUCT_PACKAGES += \
    lineage.touch@1.0-service.hi6250

# NFC: none of the AGS2 tablets have NFC hardware, so no NfcNci/HAL/features here.
# Landscape default (see rootdir/bin/landscape_default.sh)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/bin/landscape_default.sh:$(TARGET_COPY_OUT_VENDOR)/bin/landscape_default.sh

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:system/etc/permissions/android.hardware.fingerprint.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:system/etc/permissions/android.hardware.telephony.gsm.xml

# Recovery
PRODUCT_PACKAGES += \
    resize2fs_static

# Trust HAL
PRODUCT_PACKAGES += \
    lineage.trust@1.0-service
