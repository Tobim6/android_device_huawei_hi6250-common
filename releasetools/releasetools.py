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
import math
import re
import struct
import sys

def DropCompatibilityZip():
    # ota_from_target_files adds compatibility.zip (vendor/system VINTF manifests) to every Treble OTA and recovery
    # then refuses to flash the package on this device. There is no option to turn it off, so neutralise the step
    # (called later than this hook, which runs from the *_Assertions entry points).
    for name in ('__main__', 'ota_from_target_files'):
        mod = sys.modules.get(name)
        if mod is not None and hasattr(mod, 'AddCompatibilityArchiveIfTrebleEnabled'):
            mod.AddCompatibilityArchiveIfTrebleEnabled = lambda *args, **kwargs: None

def _image_bytes(zf, name):
    # size of IMAGES/<name>.img in the target files: sparse image header (blk_sz * total_blks) or the plain file length
    zi = zf.getinfo("IMAGES/%s.img" % name)
    with zf.open(zi) as f:
        head = f.read(28)
    if len(head) == 28 and struct.unpack("<I", head[:4])[0] == 0xED26FF3A:
        blk_sz, total_blks = struct.unpack("<II", head[12:20])
        return blk_sz * total_blks
    return zi.file_size

def FullOTA_InstallBegin(info):
    # AGS2: the zip repartitions the eMMC from "preas" on, sized for the images in this very zip (device/huawei/AGS2/repartition).
    # The script skips by itself when the table is already repartitioned and big enough, and aborts on any unexpected table.
    try:
        info.input_zip.getinfo("INSTALL/bin/repartition.sh")
    except KeyError:
        return
    mib = 1024 * 1024
    system_mib = int(math.ceil(_image_bytes(info.input_zip, "system") / float(mib)))
    vendor_mib = int(math.ceil(_image_bytes(info.input_zip, "vendor") / float(mib)))
    info.script.Print("Checking the partition table (system %d MiB, vendor %d MiB)..." % (system_mib, vendor_mib))
    info.script.UnpackPackageDir("install", "/tmp/install")
    info.script.SetPermissionsRecursive("/tmp/install/bin", 0, 0, 0755, 0755, None, None)
    info.script.AppendExtra('assert(run_program("/tmp/install/bin/repartition.sh", "%d", "%d") == 0);' % (system_mib, vendor_mib))

def FullOTA_Assertions(info):
    DropCompatibilityZip()
    try:
        info.input_zip.getinfo("INSTALL/bin/repartition.sh")
        # AGS2: this package repartitions the eMMC and flashes vendor itself; the installed vendor's build id is meaningless (and
        # unreadable after the repartition), so huawei.verify_vendor_build_id() would abort a perfectly good install.
    except KeyError:
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
