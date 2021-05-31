#
# MIT License
#
# Copyright (c) 2020-2021 EntySec
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

include $(THEOS)/makefiles/common.mk
export TARGET = iphone:clang:13.0

TOOL_NAME               = pwny
ARCHS                   = arm64 arm64e

pwny_FILES              = src/main.mm src/pwny.m src/console.m src/utils.m
pwny_FRAMEWORKS         = Foundation Security AudioToolbox CoreFoundation MediaPlayer UIKit AVFoundation CoreLocation
pwny_PRIVATE_FRAMEWORKS = SpringBoardServices IOSurface 
pwny_CFLAGS             = -fobjc-arc
pwny_CODESIGN_FLAGS     = -Ssign.plist

include $(THEOS_MAKE_PATH)/tool.mk
