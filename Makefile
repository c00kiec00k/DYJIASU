# Makefile 修正版
ARCHS = arm64
TARGET = iphone:clang:16.5:13.0
INSTALL_TARGET_PROCESSES = TikTok

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TiktokSpeed

TiktokSpeed_FILES = Tweak.xm
TiktokSpeed_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-objc-protocol-method-implementation

include $(THEOS_MAKE_PATH)/tweak.mk