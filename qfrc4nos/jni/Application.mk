# Copyright (c) 2021-2022 Quram Co., Ltd.
# All Rights Reserved.
# Confidential and Proprietary - Quram Co., Ltd.

NDK_TOOLCHAIN_VERSION := clang

APP_PLATFORM := android-29
APP_ABI := arm64-v8a armeabi-v7a
APP_STL := c++_shared
APP_CPPFLAGS += -std=c++17 -fexceptions -frtti -nostdlib++
# APP_STL := c++_static
# APP_CPPFLAGS += -std=c++14 -fexceptions -frtti 
APP_ALLOW_MISSING_DEPS := false

# 16kb alignment option when NDK > 26
# when NDK <= 26, Android.mk adds option
NDK_VERSION := $(shell ./check_ndk_version.sh)
ifneq ($(NDK_VERSION),)
  ifeq ($(shell test $(NDK_VERSION) -gt 26 && echo yes),yes)
    APP_SUPPORT_FLEXIBLE_PAGE_SIZES := true
  endif
endif
