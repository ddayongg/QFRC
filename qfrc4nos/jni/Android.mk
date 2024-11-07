# Copyright (c) 2021-2022 Quram Co., Ltd.
# All Rights Reserved.
# Confidential and Proprietary - Quram Co., Ltd.

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

UNITTEST_ENABLE := false
QNEON_ENABLE := true

ifeq ($(TARGET_NPU_BACKEND), snpe)
   QSNPE_ENABLE := true
else
   QSNPE_ENABLE := false
endif

ifndef ($(TARGET_DEVICE))
   TARGET_DEVICE := qti
endif

ifndef ($(TARGET_DEVICE_ID))
   TARGET_DEVICE_ID := 0
endif

ifndef ($(USE_IDL))
   USE_IDL := 0
endif

ifndef ($(IDLTYPE))
   IDLTYPE := aidl
endif

ifndef ($(HWASAN))
   HWASAN := 0
endif

ifndef ($(INCLUDE_MODEL))
   INCLUDE_MODEL := 0
endif

ifndef ($(AIFRC_PACKAGE))
   AIFRC_PACKAGE := 0
endif

NPU_TYPE := 0
ifeq ($(TARGET_DEVICE), samsung)
   NPU_TYPE := 1
else ifeq ($(TARGET_DEVICE), mediatek)
   NPU_TYPE := 2
endif

USE_PCV = 1
ifeq ($(USE_IDL), 1)
   USE_PCV := 0
endif

ifndef ($(USE_SRMC))
   USE_SRMC := 0
endif

ifeq ($(NPU_TYPE), 2)
   SRRMC_DIR := sdk_mcaimegpu_packedp010_MTK
else
   SRRMC_DIR := sdk_mcaimegpu_cache_helpers
endif

LOCAL_CPP_SHARED_LIB :=
SNPE_INCLUDE_DIR := 
SNPE_LIB_DIR := 
LOCAL_SNPE_LIB := 
CL_INCLUDE_DIR := jni/qfrc/include
SRRMC_INCLUDE_DIR := jni/qfrc/$(SRRMC_DIR)/include
PCV_INCLUDE_DIR :=

ifeq ($(APP_STL), none)
   CL_INCLUDE_DIR += jni/qfrc/include/stl_libc++/include/libcxx_inc \
      jni/qfrc/include/stl_libc++/include/libcxxabi_inc \
      $(ANDROID_NDK_ROOT)/sources/android/support/include \
      $(ANDROID_NDK_ROOT)/sysroot/usr/include
   LOCAL_CPP_SHARED_LIB += c++
endif

ifeq ($(USE_PCV), 1)
   PCV_INCLUDE_DIR += jni/qfrc/pcv340/include340
endif

PKGNAME := aifrc
ifeq ($(AIFRC_PACKAGE), 0)
   PKGNAME := frc
endif

IDLNAME :=
ifeq ($(USE_IDL), 1)
   IDLNAME := .$(IDLTYPE)
endif

# 16kb alignment option when NDK <= 26
# when NDK > 26, Application.mk adds option
ADD_16KB_ALIGNMENT := 0
NDK_VERSION := $(shell ./check_ndk_version.sh)
ifneq ($(NDK_VERSION),)
  ifeq ($(shell test $(NDK_VERSION) -le 26 && echo yes),yes)
    ADD_16KB_ALIGNMENT := 1
    LDFLAGS_16KB_ALIGNMENT := "-Wl,-z,max-page-size=16384"
  endif
endif

GIT_VERSION := \"$(shell git rev-parse --short=8 HEAD)\"

$(info -- Android.mk ($(TARGET_ARCH_ABI)))
$(info | TARGET_DEVICE    : $(TARGET_DEVICE))
$(info | TARGET_DEVICE_ID : $(TARGET_DEVICE_ID))
$(info | GIT_VERSION      : $(GIT_VERSION))
$(info | INCLUDE_MODEL    : $(INCLUDE_MODEL))
$(info | AIFRC_PACKAGE    : $(AIFRC_PACKAGE))
$(info | USE_IDL          : $(USE_IDL))
$(info | IDLTYPE          : $(IDLTYPE))
$(info | USE_PCV          : $(USE_PCV))
$(info | NPU_TYPE         : $(NPU_TYPE))
$(info | HWASAN           : $(HWASAN))
$(info | USE_SRMC         : $(USE_SRMC))
$(info -------------------------)

ifeq ($(QSNPE_ENABLE), true)
   LOCAL_SNPE_LIB := SNPE
   ifeq ($(TARGET_ARCH_ABI), arm64-v8a)
         SNPE_LIB_DIR := $(SNPE_ROOT)/lib/aarch64-android-clang8.0
   else ifeq ($(TARGET_ARCH_ABI), armeabi-v7a)
         SNPE_LIB_DIR := $(SNPE_ROOT)/lib/arm-android-clang8.0
   else
      $(error Unsupported TARGET_ARCH_ABI: '$(TARGET_ARCH_ABI)')
   endif
endif 

ifeq ($(TARGET_ARCH_ABI), armeabi-v7a)

   include $(CLEAR_VARS)
      LOCAL_MODULE := $(PKGNAME)$(IDLNAME).quram
      LOCAL_CFLAGS := -fstrict-aliasing -fprefetch-loop-arrays -mfloat-abi=softfp -O3
      LOCAL_CFLAGS += -DTARGET_DEVICE=$(TARGET_DEVICE) -DTARGET_DEVICE_ID=$(TARGET_DEVICE_ID) -DQFRC_VER_REVISION=$(GIT_VERSION) -DDUMMYLIB=$(TARGET_ARCH_ABI) -DAIFRC_PACKAGE=$(AIFRC_PACKAGE) -DUSE_IDL=$(USE_IDL)
      ifeq ($(AIFRC_PACKAGE), 1)
         LOCAL_SRC_FILES := qfrc/AIFRC.cpp qfrc/QImage.cpp 
      else
         LOCAL_SRC_FILES := qfrc/QFRC.cpp qfrc/QImage.cpp 
      endif
      LOCAL_LDLIBS := -llog
      ifeq ($(ADD_16KB_ALIGNMENT), 1)
         LOCAL_LDFLAGS += $(LDFLAGS_16KB_ALIGNMENT)
      endif

      LOCAL_C_INCLUDES += $(CL_INCLUDE_DIR) 
   include $(BUILD_SHARED_LIBRARY)

else

   include $(CLEAR_VARS)
      LOCAL_MODULE := $(PKGNAME)
      LOCAL_CFLAGS := -fstrict-aliasing -fprefetch-loop-arrays -mfloat-abi=softfp -Wno-everything -O3 
      LOCAL_CFLAGS += -DTARGET_DEVICE=$(TARGET_DEVICE) -DTARGET_DEVICE_ID=$(TARGET_DEVICE_ID) -DQFRC_VER_REVISION=$(GIT_VERSION) -DQFRC_ARM64=1 -DINCLUDE_MODEL=$(INCLUDE_MODEL) -DAIFRC_PACKAGE=$(AIFRC_PACKAGE) -DNPU_TYPE=$(NPU_TYPE) -DUSE_PCV=$(USE_PCV) -DUSE_IDL=$(USE_IDL)

      ifeq ($(QNEON_ENABLE), true)
         LOCAL_ARM_NEON := true
         LOCAL_CFLAGS += -DUSE_NEON=1 -mfpu=neon
      else
         LOCAL_CFLAGS += -DUSE_NEON=0
      endif

      LOCAL_SRC_FILES := \
         qfrc/QFRCNative.cpp \
         qfrc/QImage.cpp \
         qfrc/QImagePool.cpp \
         qfrc/ColorFormatUtil.cpp \
         qfrc/CompressUtil.cpp \
         qfrc/QfrcManager.cpp \
         qfrc/QfrcSnap.cpp \
         qfrc/QfrcME.cpp \
         qfrc/QfrcIIP.cpp \
         qfrc/QfrcIPCL.cpp \
         qfrc/QfrcFD.cpp \
         qfrc/QfrcComplexity.cpp \
         qfrc/QfrcJob.cpp \
         qfrc/OpenCLWrapper.cpp

      ifeq ($(USE_SRMC), 1)
         LOCAL_SRC_FILES += qfrc/QfrcMCSR.cpp
         LOCAL_CFLAGS += -DUSE_SRMC=1
      else
         LOCAL_SRC_FILES += qfrc/QfrcMCCL.cpp
         LOCAL_CFLAGS += -DUSE_SRMC=0
      endif 

      ifeq ($(AIFRC_PACKAGE), 1)
         LOCAL_SRC_FILES += qfrc/AIFRC.cpp
      else
         LOCAL_SRC_FILES += qfrc/QFRC.cpp
      endif

      ifeq ($(INCLUDE_MODEL), 1)         
         LOCAL_SRC_FILES += qfrc/QfrcModels.cpp
      endif

      ifeq ($(QSNPE_ENABLE), true)
         SNPE_INCLUDE_DIR := $(SNPE_ROOT)/include/zdl
         SNPE_SRC_DIR := snpes231
         LOCAL_CFLAGS += -DUSE_SNPE=1
         LOCAL_SRC_FILES += qfrc/QfrcSnpe.cpp \
            qfrc/${SNPE_SRC_DIR}/LoadInputTensor.cpp \
            qfrc/${SNPE_SRC_DIR}/CreateUserBuffer.cpp \
            qfrc/${SNPE_SRC_DIR}/Util.cpp \
            qfrc/${SNPE_SRC_DIR}/PreprocessInput.cpp \
            qfrc/${SNPE_SRC_DIR}/SaveOutputTensor.cpp
      endif

      ifeq ($(USE_PCV), 1)
         LOCAL_SHARED_LIBRARIES += pcv
      endif

      ifeq ($(ADD_16KB_ALIGNMENT), 1)
         LOCAL_LDFLAGS += $(LDFLAGS_16KB_ALIGNMENT)
      endif

      LOCAL_C_INCLUDES += $(CL_INCLUDE_DIR) $(SNPE_INCLUDE_DIR) $(PCV_INCLUDE_DIR)
   include $(BUILD_STATIC_LIBRARY)

   include $(CLEAR_VARS)
      LOCAL_MODULE := $(PKGNAME)$(IDLNAME).quram
      LOCAL_WHOLE_STATIC_LIBRARIES := quramcore $(PKGNAME)
      ifeq ($(USE_IDL), 1)
         LOCAL_SHARED_LIBRARIES := snap_$(IDLTYPE).snap.samsung $(LOCAL_CPP_SHARED_LIB) $(LOCAL_SNPE_LIB)
      else
         LOCAL_SHARED_LIBRARIES := snap_vndk $(LOCAL_CPP_SHARED_LIB) $(LOCAL_SNPE_LIB)
      endif
      LOCAL_LDLIBS    := -lm -llog -lz
      ifeq ($(ADD_16KB_ALIGNMENT), 1)
         LOCAL_LDFLAGS += $(LDFLAGS_16KB_ALIGNMENT)
      endif

      LOCAL_C_INCLUDES += $(CL_INCLUDE_DIR) $(SNPE_INCLUDE_DIR)
   include $(BUILD_SHARED_LIBRARY)

   include $(CLEAR_VARS)
      LOCAL_MODULE := video_transcoder
      LOCAL_SRC_FILES := main_ondemand.cpp RawFileDecoder.cpp QMediaDecoder.cpp QMediaEncoder.cpp QUtils.cpp image_util.cpp
      LOCAL_CFLAGS := -DENABLE_GL_BUFFER -fstrict-aliasing -fprefetch-loop-arrays -mfloat-abi=softfp -O3
      LOCAL_CFLAGS += -DINCLUDE_MODEL=$(INCLUDE_MODEL) -DAIFRC_PACKAGE=$(AIFRC_PACKAGE) -DNPU_TYPE=$(NPU_TYPE)
      LOCAL_LDLIBS := -lGLESv2 -lEGL -lmediandk -llog
      LOCAL_SHARED_LIBRARIES := $(PKGNAME)$(IDLNAME).quram $(LOCAL_CPP_SHARED_LIB)

      ifeq ($(USE_PCV), 1)
         LOCAL_SHARED_LIBRARIES += pcv
      endif
      ifeq ($(ADD_16KB_ALIGNMENT), 1)
         LOCAL_LDFLAGS += $(LDFLAGS_16KB_ALIGNMENT)
      endif

      LOCAL_C_INCLUDES += $(CL_INCLUDE_DIR) $(PCV_INCLUDE_DIR)
   include $(BUILD_EXECUTABLE)

   # googletest static library
   ifeq ($(UNITTEST_ENABLE), true)
      include $(CLEAR_VARS)
         GTEST_PATH := tests/googletest
         LOCAL_MODULE := googletest_main
         LOCAL_CFLAGS := -Ijni/tests/googletest/include -Ijni/tests/googletest/
         LOCAL_SRC_FILES := $(GTEST_PATH)/src/gtest-all.cc
         LOCAL_SHARED_LIBRARIES += $(LOCAL_CPP_SHARED_LIB)
      include $(BUILD_STATIC_LIBRARY)

      # unit test case executalbe files
      include $(CLEAR_VARS)
         LOCAL_MODULE := testcases
         LOCAL_SRC_FILES := tests/test_main.cpp QMediaDecoder.cpp QMediaEncoder.cpp QUtils.cpp 
         LOCAL_CFLAGS := -DENABLE_GL_BUFFER -fstrict-aliasing -fprefetch-loop-arrays -mfloat-abi=softfp -O3 
         LOCAL_CFLAGS += -Ijni/tests/googletest/include -Ijni
         LOCAL_LDLIBS := -lGLESv2 -lEGL -lmediandk -llog
         LOCAL_SHARED_LIBRARIES := $(PKGNAME)$(IDLNAME).quram $(LOCAL_CPP_SHARED_LIB)
         LOCAL_STATIC_LIBRARIES := googletest_main
         LOCAL_C_INCLUDES += $(CL_INCLUDE_DIR) 
      include $(BUILD_EXECUTABLE)
   endif 

   ifeq ($(QSNPE_ENABLE), true)
      include $(CLEAR_VARS)
         LOCAL_MODULE := ${LOCAL_SNPE_LIB}
         LOCAL_SRC_FILES := qfrc/libs/libSNPE.so 
         LOCAL_EXPORT_C_INCLUDES += $(SNPE_INCLUDE_DIR)
      include $(PREBUILT_SHARED_LIBRARY)
   endif

   include $(CLEAR_VARS)
      LOCAL_MODULE := snap_$(IDLTYPE).snap.samsung
      LOCAL_SRC_FILES := qfrc/libs/libsnap_$(IDLTYPE).snap.samsung.so
      ifeq ($(ADD_16KB_ALIGNMENT), 1)
         LOCAL_LDFLAGS += $(LDFLAGS_16KB_ALIGNMENT)
      endif
   include $(PREBUILT_SHARED_LIBRARY)

   include $(CLEAR_VARS)
      LOCAL_MODULE := snap_vndk
      LOCAL_SRC_FILES := qfrc/libs/libsnap_vndk.so
      ifeq ($(ADD_16KB_ALIGNMENT), 1)
         LOCAL_LDFLAGS += $(LDFLAGS_16KB_ALIGNMENT)
      endif
   include $(PREBUILT_SHARED_LIBRARY)

   # include $(CLEAR_VARS)
   #    LOCAL_MODULE := OpenCL
   #    LOCAL_SRC_FILES := qfrc/libs/libOpenCL.so
   # include $(PREBUILT_SHARED_LIBRARY)
   
   include $(CLEAR_VARS)
      LOCAL_MODULE := mcaimegpu
      ifeq ($(USE_IDL), 1)
         ifeq ($(HWASAN), 1)
            LOCAL_SRC_FILES := qfrc/$(SRRMC_DIR)/$(TARGET_ARCH_ABI)-c++-hwasan/libmcaimegpu.samsung.so
         else
            LOCAL_SRC_FILES := qfrc/$(SRRMC_DIR)/$(TARGET_ARCH_ABI)-c++/libmcaimegpu.samsung.so
         endif
      else
         ifeq ($(HWASAN), 1)
            LOCAL_SRC_FILES := qfrc/$(SRRMC_DIR)/$(TARGET_ARCH_ABI)-c++-hwasan/libmcaimegpu.samsung.so
         else
            LOCAL_SRC_FILES := qfrc/$(SRRMC_DIR)/$(TARGET_ARCH_ABI)-c++/libmcaimegpu.samsung.so
         endif
      endif
      ifeq ($(ADD_16KB_ALIGNMENT), 1)
         LOCAL_LDFLAGS += $(LDFLAGS_16KB_ALIGNMENT)
      endif
   include $(PREBUILT_SHARED_LIBRARY)
   
   
   ifeq ($(USE_PCV), 1)
      include $(CLEAR_VARS)
         LOCAL_MODULE := pcv
         LOCAL_SRC_FILES := qfrc/pcv340/libs/$(TARGET_ARCH_ABI)/libOpenCv.camera.samsung.so
         ifeq ($(ADD_16KB_ALIGNMENT), 1)
            LOCAL_LDFLAGS += $(LDFLAGS_16KB_ALIGNMENT)
         endif
      include $(PREBUILT_SHARED_LIBRARY)
   endif

   ifeq ($(APP_STL), none)
      include $(CLEAR_VARS)
         LOCAL_MODULE := $(LOCAL_CPP_SHARED_LIB)
         LOCAL_SRC_FILES := qfrc/libs/libc++.so
         ifeq ($(ADD_16KB_ALIGNMENT), 1)
            LOCAL_LDFLAGS += $(LDFLAGS_16KB_ALIGNMENT)
         endif
      include $(PREBUILT_SHARED_LIBRARY)
   endif

   include $(LOCAL_PATH)/qjpeg/projects/samsung/jni/Android.mk

endif
