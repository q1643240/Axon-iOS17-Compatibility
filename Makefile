# Axon iOS 16–17 compatibility maintenance.
# Usage:
#   make clean package THEOS_PACKAGE_SCHEME=rootless
#   make clean package THEOS_PACKAGE_SCHEME=roothide

THEOS_PACKAGE_SCHEME ?= roothide
FINALPACKAGE = 1
DEBUG = 0
ARCHS = arm64e
TARGET = iphone:16.0:16.0

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += Tweak Prefs

include $(THEOS_MAKE_PATH)/aggregate.mk
