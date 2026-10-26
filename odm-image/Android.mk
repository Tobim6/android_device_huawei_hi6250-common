# This LineageOS 16.0 build/make has no ODM image support, but the AGS2 ships ~95 MB of camera/audio/sensor files in
# /odm (a separate 128 MB ext4 partition). The ODM files are staged in $(PRODUCT_OUT)/odm by PRODUCT_COPY_FILES
# (AGS2-vendor-odm.mk); build an image from them, ship it in the target-files zip (RADIO/odm.img) and flash it from the
# OTA (releasetools.py FullOTA_InstallEnd).
LOCAL_PATH := $(call my-dir)

ODM_IMAGE_TARGET := $(PRODUCT_OUT)/odm.img

# every file PRODUCT_COPY_FILES installs below $(PRODUCT_OUT)/odm (plus the SELinux file_contexts for labelling)
ODM_IMAGE_FILES := $(filter $(PRODUCT_OUT)/odm/%,$(foreach cf,$(PRODUCT_COPY_FILES),$(PRODUCT_OUT)/$(word 2,$(subst :, ,$(cf)))))
ODM_FILE_CONTEXTS := $(PRODUCT_OUT)/obj/ETC/file_contexts.bin_intermediates/file_contexts.bin

$(ODM_IMAGE_TARGET): $(ODM_IMAGE_FILES) $(ODM_FILE_CONTEXTS)
	@echo "Target odm fs image: $@"
	@mkdir -p $(PRODUCT_OUT)/odm
	$(hide) rm -f $@
	$(hide) MKE2FS_CONFIG=$(HOST_OUT_EXECUTABLES)/mke2fs.conf PATH=$(HOST_OUT_EXECUTABLES):$$PATH \
	    $(HOST_OUT_EXECUTABLES)/mkuserimg_mke2fs.sh $(PRODUCT_OUT)/odm $@ ext4 /odm \
	    $(BOARD_ODMIMAGE_PARTITION_SIZE) -D $(PRODUCT_OUT) -L odm \
	    $(PRODUCT_OUT)/obj/ETC/file_contexts.bin_intermediates/file_contexts.bin
	$(hide) test -s $@

.PHONY: odmimage
odmimage: $(ODM_IMAGE_TARGET)

# goes into target_files (RADIO/odm.img) and the dist dir
INSTALLED_RADIOIMAGE_TARGET += $(ODM_IMAGE_TARGET)
