#!/vendor/bin/sh
# Runs from init at post-fs-data, before zygote/system_server start, so the window manager reads
# ROTATION_90 the first time instead of coming up portrait and rotating ~2s later.
# Edits in place with cat > (keeps the file's owner/mode/label, which system_server needs).
F=/data/system/users/0/settings_system.xml
[ -f "$F" ] || exit 0
grep -q 'name="user_rotation" value="1"' "$F" && exit 0
sed 's/name="user_rotation" value="[0-9]*"/name="user_rotation" value="1"/' "$F" > /data/local/tmp/ss_rot.xml \
    && cat /data/local/tmp/ss_rot.xml > "$F"
rm -f /data/local/tmp/ss_rot.xml
exit 0
