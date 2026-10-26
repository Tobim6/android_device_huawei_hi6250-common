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

import common
import re
import sys

def DropCompatibilityZip():
    # ota_from_target_files adds compatibility.zip (vendor/system VINTF manifests) to every Treble OTA and recovery
    # then refuses to flash the package on this device. There is no option to turn it off, so neutralise the step
    # (called later than this hook, which runs from the *_Assertions entry points).
    for name in ('__main__', 'ota_from_target_files'):
        mod = sys.modules.get(name)
        if mod is not None and hasattr(mod, 'AddCompatibilityArchiveIfTrebleEnabled'):
            mod.AddCompatibilityArchiveIfTrebleEnabled = lambda *args, **kwargs: None

def FullOTA_Assertions(info):
    DropCompatibilityZip()
    AddVendorAssertion(info, info.input_zip)

def IncrementalOTA_Assertions(info):
    DropCompatibilityZip()
    AddVendorAssertion(info, info.target_zip)

def FullOTA_PostValidate(info):
    info.script.AppendExtra('run_program("/sbin/e2fsck", "-fy", "/dev/block/bootdevice/by-name/system");');
    info.script.AppendExtra('run_program("/tmp/install/bin/resize2fs_static", "/dev/block/bootdevice/by-name/system");');
    info.script.AppendExtra('run_program("/sbin/e2fsck", "-fy", "/dev/block/bootdevice/by-name/system");');

def AddVendorAssertion(info, input_zip):
    android_info = input_zip.read("OTA/android-info.txt")
    m = re.search(r'require\s+vendor-build-id\s*=\s*(.+)', android_info)
    if m:
        cmd = 'assert(huawei.verify_vendor_build_id("' + m.group(1).rstrip() + '") == "1");'
        info.script.AppendExtra(cmd)

def FullOTA_InstallEnd(info):
    # /odm is a separate partition that LineageOS 16.0's build system cannot build; the device tree builds odm.img
    # (odm-image/Android.mk) and ships it as RADIO/odm.img.
    try:
        odm = info.input_zip.read("RADIO/odm.img")
    except KeyError:
        return
    common.ZipWriteStr(info.output_zip, "odm.img", odm)
    info.script.Print("Flashing odm...")
    info.script.AppendExtra('package_extract_file("odm.img", "/dev/block/bootdevice/by-name/odm");')
