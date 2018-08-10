# Release name
PRODUCT_RELEASE_NAME := h918

# Inherit from the common Open Source product configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)

# Inherit from our custom product configuration
$(call inherit-product, vendor/omni/config/common.mk)

PRODUCT_PACKAGES += \
	charger_res_images \
	charger

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := h918
PRODUCT_MODEL := LG-H918
PRODUCT_NAME := omni_h918
PRODUCT_BRAND := lge
PRODUCT_MANUFACTURER := LGE
PRODUCT_COPY_FILES += device/lge/$(PRODUCT_DEVICE)/twrp.flags:recovery/root/etc/twrp.flags
PRODUCT_COPY_FILES += bionic/libc/zoneinfo/tzdata:recovery/root/system/usr/share/zoneinfo/tzdata
