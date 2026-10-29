#!/system/bin/sh
# Runs from init at post-fs-data, before zygote/system_server start, so the window manager reads
# ROTATION_90 the first time instead of coming up portrait and rotating ~2s later.
# This script only prepares the patched copy (ss_rot.xml); init.ags2_core.rc then copies it over settings_system.xml with
# init's own "copy", which rewrites the file in place (keeps owner/mode/label, which system_server needs). A helper
# script may not write system_data_file itself under SELinux.
F=/data/system/users/0/settings_system.xml
[ -f "$F" ] || exit 0
grep -q 'name="user_rotation" value="1"' "$F" && exit 0
sed 's/name="user_rotation" value="[0-9]*"/name="user_rotation" value="1"/' "$F" > /data/system/users/0/ss_rot.xml
exit 0
