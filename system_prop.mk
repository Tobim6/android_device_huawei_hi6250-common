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

# Audio
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.media_vol_steps=25 \
    ro.config.vc_call_vol_steps=7

# Connectivity
# Stock EMUI8's patched init derives these from the device tree
# (/proc/device-tree/hw_connectivity/chip_type = hisi, hi1102 node present) before it
# parses any rc. Without them init.connectivity.rc imports an empty-named file and the
# gnss/wifi HALs cannot pick their chip (gps.hi1102.default.so via gps_hardware_id).
PRODUCT_PROPERTY_OVERRIDES += \
    ro.connectivity.chiptype=hisi \
    ro.connectivity.sub_chiptype=hi1102

# Perf
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.qti.sys.fw.bg_apps_limit=60

# USB
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.cust.cdrom=/dev/null
