ARCHS = arm64e
TARGET = iphone:16.5:16.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Axon17
Axon17_FILES = Tweak.xm $(wildcard AXN*.m)
Axon17_FRAMEWORKS += QuartzCore WebKit MediaPlayer
Axon17_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk