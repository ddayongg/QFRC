#
# Copyright (C) 2015. QuramSoft all rights reserved
#

############################################################
LOCAL_PATH := $(call my-dir)

############################################################
include $(CLEAR_VARS)

LOCAL_CFLAGS += -DLINUX=1
LOCAL_CFLAGS += -Wno-everything

LOCAL_ARM_MODE := arm

LOCAL_MODULE    := quramcore

LOCAL_CFLAGS += -DMIN_SDK_VER=28
LOCAL_CFLAGS += -DMIN_SDK_VER_FOR_QRCMS=33

# skia porting
# LOCAL_SRC_FILES += ./src/qjpeg.c

# resize
LOCAL_SRC_FILES += ./src/wink/WINKCommonLib/qresize.c

# rotate
LOCAL_SRC_FILES += ./src/wink/WINKCommonLib/qrotate.c

# flip
LOCAL_SRC_FILES += ./src/wink/WINKCommonLib/qr_flip.c

# csc
LOCAL_SRC_FILES += ./src/wink/csc/csc_converter.c

# native api
# LOCAL_SRC_FILES += ./src/QrBitmapFactory.c
# LOCAL_SRC_FILES += ./src/QrBitmapRegionDecoder.c
# LOCAL_SRC_FILES += ./src/QrUtils.cpp

# threadpool
#LOCAL_SRC_FILES += ./src/qthreadpool/QuramThreadpool.c
LOCAL_SRC_FILES += ./src/wink/WINKCommonLib/qr_threadpool.c

# qjpeg decoder
#LOCAL_SRC_FILES += ./src/wink/WINKCommonLib/jstat.c
LOCAL_SRC_FILES += ./src/wink/WINKJpegPreviewer/WINKJ_DecLib_Red.c
LOCAL_SRC_FILES += ./src/wink/WINKJpegPreviewer/WINKJ_DecLib_Color.c
LOCAL_SRC_FILES += ./src/wink/WINKJpegPreviewer/WINKJ_DecLib_Huff.c
LOCAL_SRC_FILES += ./src/wink/WINKJpegPreviewer/WINKJ_DecLib_DecodeMCU.c
LOCAL_SRC_FILES += ./src/wink/WINKJpegPreviewer/WINKJ_DecLib_Idct.c
LOCAL_SRC_FILES += ./src/wink/WINKJpegPreviewer/WINKJ_DecLib_Iter.c
LOCAL_SRC_FILES += ./src/wink/WINKJpegPreviewer/WINKJ_DecLib_Sample.c
LOCAL_SRC_FILES += ./src/wink/WINKJpegPreviewer/WINKJ_DecLib_Dualcore.c
LOCAL_SRC_FILES += ./src/wink/WINKCommonLib/QuramWinkPaser.c
LOCAL_SRC_FILES += ./src/wink/WINKCommonLib/QuramWink_CheckFn.c
LOCAL_SRC_FILES += ./src/wink/WINKCommonLib/QuramWinkDecInfo.c
LOCAL_SRC_FILES += ./src/wink/WINKCommonLib/QuramWink_IO.c
LOCAL_SRC_FILES += ./src/wink/WINK_PortingLayer/QuramWink_Os_Interface.c

ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
LOCAL_CFLAGS += -D_X64=1
endif

# qjpeg utils
LOCAL_SRC_FILES += ./src/wink/WINKImageEditor/wink_codec_api.c
LOCAL_SRC_FILES += ./src/wink/WINKCommonLib/QrImageUtils.c
LOCAL_SRC_FILES += ./src/wink/WINKCommonLib/QjpgDecode.c
LOCAL_SRC_FILES += ./src/wink/WINKCommonLib/QuramDecode.c
# LOCAL_SRC_FILES += ./src/wink/WINKJpegEncoder/JpegCaptureOTF.c
LOCAL_SRC_FILES += ./src/wink/WINKCommonLib/qjpeg_pool.c

# qjpeg encoder
LOCAL_SRC_FILES += ./src/wink/WINKJpegEncoder/wink_jpeg_enc.c
LOCAL_SRC_FILES += ./src/wink/WINKJpegEncoder/wink_jpeg_enc_huff_opt.c
LOCAL_SRC_FILES += ./src/wink/WINKJpegEncoder/wink_jpeg_enc_adv.c
LOCAL_SRC_FILES += ./src/wink/WINKJpegEncoder/wink_jpeg_enc_mcu.c
LOCAL_SRC_FILES += ./src/wink/WINKJpegEncoder/wink_jpeg_enc_util.c
LOCAL_SRC_FILES += ./src/wink/WINKJpegEncoder/wink_jpeg_enc_exif_creator.c

# qbmp
QBMP_ENABLE := false
ifeq ($(QBMP_ENABLE),true)
LOCAL_SRC_FILES += ./src/wink/WINKImagePreviewer/QuramWinkI_DecodeBmp.c
LOCAL_CFLAGS += -DUSE_QBMP=1
else
LOCAL_CFLAGS += -DUSE_QBMP=0
endif

# qwbmp
QWBMP_ENABLE := false
ifeq ($(QBMP_ENABLE),true)
LOCAL_SRC_FILES += ./src/wink/WINKImagePreviewer/QuramWinkI_DecodeWbmp.c
LOCAL_CFLAGS += -DUSE_QWBMP=1
else
LOCAL_CFLAGS += -DUSE_QWBMP=0
endif

# qgif
QGIF_ENABLE := false
ifeq ($(QGIF_ENABLE),true)
LOCAL_SRC_FILES += ./src/wink/WINKImagePreviewer/QuramWinkI_GIF.c
LOCAL_CFLAGS += -DUSE_QGIF=1
else
LOCAL_CFLAGS += -DUSE_QGIF=0
endif

# qpng
QPNG_ENABLE := false
ifeq ($(QPNG_ENABLE),true)
LOCAL_SRC_FILES += ./src/libqpng/qpngapi.c
LOCAL_SRC_FILES += ./src/libqpng/qpng.c
LOCAL_SRC_FILES += ./src/libqpng/qpngerror.c
LOCAL_SRC_FILES += ./src/libqpng/qpngget.c
LOCAL_SRC_FILES += ./src/libqpng/qpngmem.c
LOCAL_SRC_FILES += ./src/libqpng/qpngpread.c
LOCAL_SRC_FILES += ./src/libqpng/qpngread.c
LOCAL_SRC_FILES += ./src/libqpng/qpngrio.c
LOCAL_SRC_FILES += ./src/libqpng/qpngrtran.c
LOCAL_SRC_FILES += ./src/libqpng/qpngrutil.c
LOCAL_SRC_FILES += ./src/libqpng/qpngset.c
LOCAL_SRC_FILES += ./src/libqpng/qpngtrans.c
LOCAL_SRC_FILES += ./src/libqpng/qpngwio.c
LOCAL_SRC_FILES += ./src/libqpng/qpngwrite.c
LOCAL_SRC_FILES += ./src/libqpng/qpngwtran.c
LOCAL_SRC_FILES += ./src/libqpng/qpngwutil.c
LOCAL_SRC_FILES += ./src/libqpng/arm/arm_init.c
LOCAL_SRC_FILES += ./src/libqpng/arm/filter_neon.S
LOCAL_SRC_FILES += ./src/libqpng/arm/filter_neon_intrinsics.c
LOCAL_SRC_FILES += ./src/libqpng/arm/palette_neon_intrinsics.c

ifeq ($(ARCH_ARM_HAVE_NEON),true)
my_cflags_arm := -DQPNG_ARM_NEON_OPT=2
endif
my_cflags_arm64 := -DQPNG_ARM_NEON_OPT=2

my_cflags_arm += -fno-slp-vectorize

LOCAL_CFLAGS += -DUSE_QPNG=1
else
LOCAL_CFLAGS += -DUSE_QPNG=0
endif

# sk_icc
SKICC_ENABLE := true
ifeq ($(SKICC_ENABLE),true)
LOCAL_SRC_FILES += ./src/wink/skcms/skcms.cc
LOCAL_SRC_FILES += ./src/wink/skcms/qrcms.cpp
LOCAL_CFLAGS += -DUSE_QRCMS=1
endif

# icc
QICC_ENABLE := false
ifeq ($(QICC_ENABLE),true)
LOCAL_SRC_FILES += ./src/wink/WINKJpegPreviewer/qjpegicc.c
LOCAL_SRC_FILES += ./src/wink/icc/cmsalpha.c
LOCAL_SRC_FILES += ./src/wink/icc/cmscam02.c
LOCAL_SRC_FILES += ./src/wink/icc/cmscgats.c
LOCAL_SRC_FILES += ./src/wink/icc/cmscnvrt.c
LOCAL_SRC_FILES += ./src/wink/icc/cmserr.c
LOCAL_SRC_FILES += ./src/wink/icc/cmsgamma.c
LOCAL_SRC_FILES += ./src/wink/icc/cmsgmt.c
LOCAL_SRC_FILES += ./src/wink/icc/cmshalf.c
LOCAL_SRC_FILES += ./src/wink/icc/cmsintrp.c
LOCAL_SRC_FILES += ./src/wink/icc/cmsio0.c
LOCAL_SRC_FILES += ./src/wink/icc/cmsio1.c
LOCAL_SRC_FILES += ./src/wink/icc/cmslut.c
LOCAL_SRC_FILES += ./src/wink/icc/cmsmd5.c
LOCAL_SRC_FILES += ./src/wink/icc/cmsmtrx.c
LOCAL_SRC_FILES += ./src/wink/icc/cmsnamed.c
LOCAL_SRC_FILES += ./src/wink/icc/cmsopt.c
LOCAL_SRC_FILES += ./src/wink/icc/cmspack.c
LOCAL_SRC_FILES += ./src/wink/icc/cmspcs.c
LOCAL_SRC_FILES += ./src/wink/icc/cmsplugin.c
LOCAL_SRC_FILES += ./src/wink/icc/cmsps2.c
LOCAL_SRC_FILES += ./src/wink/icc/cmssamp.c
LOCAL_SRC_FILES += ./src/wink/icc/cmssm.c
LOCAL_SRC_FILES += ./src/wink/icc/cmstypes.c
LOCAL_SRC_FILES += ./src/wink/icc/cmsvirt.c
LOCAL_SRC_FILES += ./src/wink/icc/cmswtpnt.c
LOCAL_SRC_FILES += ./src/wink/icc/cmsxform.c
LOCAL_SRC_FILES += ./src/wink/icc/common/vprf.c
LOCAL_SRC_FILES += ./src/wink/icc/common/xgetopt.c
LOCAL_CFLAGS += -DUSE_ICC=1
else
LOCAL_CFLAGS += -DUSE_ICC=0
endif


# support multi thread
LOCAL_CFLAGS += -DSUPPORT_WINKJ_NORMAL_DUALCORE=1
LOCAL_CFLAGS += -DSUPPORT_WINKJ_REGION_DUALCORE=0

##############################################################
# NEON
##############################################################

ifeq ($(TARGET_ARCH_ABI),armeabi)
LOCAL_CFLAGS    += -O3 -DLINUX=1 -fstrict-aliasing -fprefetch-loop-arrays -mfloat-abi=softfp
else ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
LOCAL_CFLAGS += -DHAVE_NEON=1 -DHAVE_NEON_DCT=1 -DHAVE_NEON_ENC=1
LOCAL_CFLAGS    += -O3 -fstrict-aliasing -fprefetch-loop-arrays -mfloat-abi=softfp -fno-integrated-as -mfpu=neon
LOCAL_SRC_FILES += ./src/wink/WINKJpegPreviewer/qjsimd_arm_neon.S
LOCAL_SRC_FILES += ./src/wink/WINKJpegPreviewer/qjsimd_fdct_islow_arm_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_memcpy_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_nv12_to_rgba_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_nv12_to_rgba_709_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_nv21_to_rgba_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_nv21_to_rgba_709_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_yuv_to_rgba_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_yuv_to_rgba_709_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_rgba_to_nv12_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_rgba_to_nv21_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_rgba_to_yuv420_neon.S
#LOCAL_SRC_FILES += ./src/wink/WINKJpegPreviewer/qjsimd_rotate_neon.S

else ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
LOCAL_CFLAGS += -DHAVE_NEON_64=1 -DHAVE_NEON_DCT_64=1 -DHAVE_NEON_ENC_64=1
LOCAL_CFLAGS    += -O3 -fstrict-aliasing
LOCAL_SRC_FILES += ./src/wink/WINKJpegPreviewer/qjsimd_arm64_neon.S
LOCAL_SRC_FILES += ./src/wink/WINKJpegPreviewer/qjsimd_fdct_islow_arm64_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_nv12_to_rgba_arm64_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_nv12_to_rgba_709_arm64_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_nv21_to_rgba_arm64_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_nv21_to_rgba_709_arm64_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_yuv_to_rgba_arm64_neon.S
LOCAL_SRC_FILES += ./src/wink/csc/jsimd_csc_yuv_to_rgba_709_arm64_neon.S
LOCAL_SRC_FILES += ./src/wink/WINKJpegPreviewer/qjsimd_rotate_arm64_neon.S

else
LOCAL_CFLAGS    += -O3 -fstrict-aliasing -fprefetch-loop-arrays
endif

LOCAL_C_INCLUDES += WINK_Includes
ifeq ($(APP_STL), none)
LOCAL_C_INCLUDES += $(ANDROID_NDK_ROOT)/sources/cxx-stl/llvm-libc++/include
endif

# libjpeg-turbo

ANDROID_ENABLE_TURBO := false

ifeq ($(ANDROID_ENABLE_TURBO),true)
LOCAL_SRC_FILES += ./src/libjpegTurbo/jcapimin.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jcapistd.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jccoefct.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jccolor.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jcdctmgr.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jchuff.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jcinit.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jcmainct.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jcmarker.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jcmaster.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jcomapi.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jcparam.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jcphuff.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jcprepct.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jcsample.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jctrans.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jcarith.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdarith.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jaricom.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdapimin.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdapistd.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdatadst.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdatasrc.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdcoefct.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdcolor.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jddctmgr.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdhuff.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdinput.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdmainct.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdmarker.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdmaster.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdmerge.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdphuff.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdpostct.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdsample.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jdtrans.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jerror.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jfdctflt.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jfdctfst.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jfdctint.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jidctflt.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jidctfst.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jidctint.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jidctred.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jmemmgr.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jmemnobs.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jquant1.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jquant2.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/jutils.c

ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
LOCAL_CFLAGS += -DWITH_SIMD=1
LOCAL_SRC_FILES += ./src/libjpegTurbo/simd/arm/jsimd.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/simd/arm/jsimd_neon.S
else ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
LOCAL_CFLAGS += -DWITH_SIMD=1
LOCAL_SRC_FILES += ./src/libjpegTurbo/simd/arm64/jsimd.c
LOCAL_SRC_FILES += ./src/libjpegTurbo/simd/arm64/jsimd_neon.S
else
LOCAL_SRC_FILES += ./src/libjpegTurbo/jsimd_none.c
endif

endif

# dng
QDNG_ENABLE := false

ifeq ($(QDNG_ENABLE),true)

LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDNGDecoderJNI.cpp

# source
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngLosslessJpeg.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngMemory.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngSafeArithmetic.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDng1dFunction.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDng1dTable.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngBadPixels.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngCameraProfile.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngColorSpace.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngColorSpec.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngDateTime.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngDecoder.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngExif.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngFingerPrint.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngGainMap.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngHueSatMap.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngIFD.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngImage.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngLensCorrection.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngLinearizationInfo.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngMatrix.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngMetadata.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngMiscOpcode.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngMosaicInfo.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngOpcode.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngOpcodeList.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngOrientation.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngRational.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngReadImage.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngRect.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngRender.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngShared.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngStream.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngException.cpp

LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngTemperature.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngUtils.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngXYCoord.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngThread.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/QuramDngNoiseReduction.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/Simd/SimdBaseMedianFilter.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/Simd/SimdNeonMedianFilter.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/Simd/SimdBaseBgrToBgra.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/Simd/SimdNeonBgrToBgra.cpp
LOCAL_SRC_FILES += ./src/DNGDecoderLib/Interface/DNGCodecInterface.cpp


#LOCAL_CFLAGS += -DUSE_SMID_FOR_SCAN
#LOCAL_CPPFLAGS += -DUSE_SMID_FOR_SCAN

ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
	ANDROID_ENABLE_NEON := true

	LOCAL_CFLAGS += -DANDROID_PLATFORM
	LOCAL_CFLAGS += -O3 -fexceptions -fstrict-aliasing -fprefetch-loop-arrays -fsigned-char -mfloat-abi=softfp -mfpu=neon -std=c99 -DQURAM_BUILD
	LOCAL_CPPFLAGS := -O3 -fexceptions -fstrict-aliasing -fprefetch-loop-arrays -fsigned-char -mfloat-abi=softfp -mfpu=neon -std=c++14 -DQURAM_BUILD
	LOCAL_CFLAGS += -DANDROID
	LOCAL_CFLAGS += -DDNG_SIMD_NEON=1
	LOCAL_CPPFLAGS += -DDNG_SIMD_NEON=1

#	LOCAL_CFLAGS += -DUSE_SMID_FOR_SCAN_NEON_ASM
#	LOCAL_CPPFLAGS += -DUSE_SMID_FOR_SCAN_NEON_ASM

else ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
	ANDROID_ENABLE_NEON := true

	#LOCAL_CFLAGS += -DSINGLE_PROCESS
	LOCAL_CFLAGS += -DANDROID_PLATFORM
	LOCAL_CFLAGS += -O3 -fexceptions -fstrict-aliasing -fprefetch-loop-arrays -fsigned-char -std=c99 -DQURAM_BUILD
	LOCAL_CPPFLAGS := -O3 -fexceptions -fstrict-aliasing -fprefetch-loop-arrays -fsigned-char -std=c++14 -DQURAM_BUILD
	LOCAL_CFLAGS += -DANDROID
	LOCAL_CFLAGS += -DDNG_SIMD_NEON=2
	LOCAL_CPPFLAGS += -DDNG_SIMD_NEON=2

#	LOCAL_CFLAGS += -DUSE_SMID_FOR_SCAN_NEON_ASM_64
#	LOCAL_CPPFLAGS += -DUSE_SMID_FOR_SCAN_NEON_ASM_64

else ifeq ($(TARGET_ARCH_ABI),x86)
	LOCAL_CFLAGS += -O3 -fexceptions -fstrict-aliasing -fprefetch-loop-arrays -fsigned-char -std=c99 -DQURAM_BUILD
	LOCAL_CFLAGS += -DANDROID_PLATFORM
	LOCAL_CPPFLAGS := -O3 -fexceptions -fstrict-aliasing -fprefetch-loop-arrays -fsigned-char -std=c++14 -DQURAM_BUILD
	LOCAL_CFLAGS += -DANDROID

#	LOCAL_CFLAGS += -DUSE_SMID_FOR_SCAN_SSE
#	LOCAL_CPPFLAGS += -DUSE_SMID_FOR_SCAN_SSE

else ifeq ($(TARGET_ARCH_ABI),x86_64)
	LOCAL_CFLAGS += -O3 -fexceptions -fstrict-aliasing -fprefetch-loop-arrays -fsigned-char -std=c99 -DQURAM_BUILD
	LOCAL_CFLAGS += -DANDROID_PLATFORM
	LOCAL_CPPFLAGS := -O3 -fexceptions -fstrict-aliasing -fprefetch-loop-arrays -fsigned-char -std=c++14 -DQURAM_BUILD
	LOCAL_CFLAGS += -DANDROID

#	LOCAL_CFLAGS += -DUSE_SMID_FOR_SCAN_SSE
#	LOCAL_CPPFLAGS += -DUSE_SMID_FOR_SCAN_SSE

else
	LOCAL_CFLAGS += -O3 -fexceptions -fstrict-aliasing -fprefetch-loop-arrays -fsigned-char -std=c99 -DQURAM_BUILD
	LOCAL_CFLAGS += -DANDROID_PLATFORM
	LOCAL_CPPFLAGS := -O3 -fexceptions -fstrict-aliasing -fprefetch-loop-arrays -fsigned-char -std=c++14 -DQURAM_BUILD
	LOCAL_CFLAGS += -DANDROID
endif

LOCAL_CPPFLAGS += -DSUPPORT_LOSSLESS_JPEG_ENC=1
LOCAL_CPPFLAGS += -DSUPPORT_LOSSLESS_JPEG_DEC=1 -DUSE_LOSSLESSJPEG_DEC=0

#LOCAL_CFLAGS += -DDEBUG_ANDROID_DNG
#LOCAL_CPPFLAGS += -DDEBUG_ANDROID_DNG
#LOCAL_CPPFLAGS += -DDEBUG -DSMID_DEBUG

LOCAL_C_INCLUDES += $(LOCAL_PATH)/src/DNGDecoderLib/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/src/DNGDecoderLib/Interface/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/src/wink/WINK_Includes/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/src/
ifeq ($(APP_STL), none)
LOCAL_C_INCLUDES += $(ANDROID_NDK_ROOT)/sources/cxx-stl/llvm-libc++/include
endif

LOCAL_CFLAGS += -DUSE_QDNG=1
else
LOCAL_CFLAGS += -DUSE_QDNG=0
endif # dng


##############################################################
# MAKE SHARED LIBRARY
##############################################################

ifeq ($(JNI_ENABLE),true)
	# jni
	LOCAL_LDLIBS    := -lm -llog -ljnigraphics -lz
else
	# LOCAL_LDLIBS    := -lm -llog -lz
endif

include $(BUILD_STATIC_LIBRARY)

# no jni
include $(CLEAR_VARS)
LOCAL_MODULE := imagecodec_native.quram

LOCAL_ARM_MODE := arm

LOCAL_CFLAGS += -DUSE_QBMP=0 -DUSE_QWBMP=0 -DUSE_QGIF=0 -DUSE_QPNG=0 -DUSE_QDNG=0
LOCAL_CFLAGS += -DSUPPORT_WINKJ_NORMAL_DUALCORE=1
LOCAL_WHOLE_STATIC_LIBRARIES := quramcore

LOCAL_LDLIBS    := -lm -llog -lz

include $(BUILD_SHARED_LIBRARY)

