THEOS_PACKAGE_DIR_NAME = debs

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SignCmdForiOS

SignCmdForiOS_FILES = Tweak.xm
SYSROOT = $(THEOS)/sdks/iPhoneOS11.2.sdk/
SignCmdForiOS_FRAMEWORKS = UIKit MessageUI Social QuartzCore CoreGraphics Foundation AVFoundation Accelerate GLKit SystemConfiguration
SignCmdForiOS_CFLAGS = -fobjc-arc
SignCmdForiOS_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG

ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS)/makefiles/aggregate.mk

after-install::
	install.exec "killall -9 '-'"