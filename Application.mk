APP_ABI := arm64-v8a armeabi-v7a
APP_PLATFORM := android-29
APP_STL := c++_shared
APP_BUILD_SCRIPT := $(call my-dir)/Android.mk

APP_CFLAGS := -g
APP_CPPFLAGS := -g

include $(CLEAR_VARS)

LOCAL_MODULE := quramcore
LOCAL_SRC_FILES := \
    jni/qfrc/quramcore/QuramWink_CheckFn.c \
    jni/qfrc/quramcore/qr_threadpool.c \
    jni/qfrc/quramcore/QuramWink_IO.c \
    jni/qfrc/quramcore/QuramWinkDecInfo.c \
    jni/qfrc/quramcore/QjpgDecode.c \
    jni/qfrc/quramcore/QuramWinkPaser.c \
    jni/qfrc/quramcore/QrImageUtils.c \
    jni/qfrc/quramcore/qjsimd_fdct_islow_arm64_neon.S \
    jni/qfrc/quramcore/QuramDecode.c \
    jni/qfrc/quramcore/qjpeg_pool.c \
    jni/qfrc/quramcore/jsimd_csc_nv12_to_rgba_arm64_neon.S \
    jni/qfrc/quramcore/jsimd_csc_nv21_to_rgba_arm64_neon.S \
    jni/qfrc/quramcore/jsimd_csc_nv12_to_rgba_709_arm64_neon.S \
    jni/qfrc/quramcore/jsimd_csc_nv21_to_rgba_709_arm64_neon.S \
    jni/qfrc/quramcore/qjsimd_rotate_arm64_neon.S \
    jni/qfrc/quramcore/qjsimd_arm64_neon.S \
    jni/qfrc/quramcore/qjsimd_csc_yuv_to_rgba_arm64_neon.S \
    jni/qfrc/quramcore/qjsimd_csc_yuv_to_rgba_709_arm64_neon.S \
    jni/qfrc/quramcore/qr_flip.c \
    jni/qfrc/quramcore/qrotate.c \
    jni/qfrc/quramcore/WINKJ_DecLib_DecodeMCU.c \
    jni/qfrc/quramcore/WINKJ_DecLib_Sample.c \
    jni/qfrc/quramcore/WINKJ_DecLib_Iter.c \
    jni/qfrc/quramcore/QuramWink_Os_Interface.c \
    jni/qfrc/quramcore/WINKJ_DecLib_Idct.c \
    jni/qfrc/quramcore/wink_codec_api.c \
    jni/qfrc/quramcore/wink_jpeg_enc_huff_opt.c \
    jni/qfrc/quramcore/WINKJ_DecLib_Dualcore.c \
    jni/qfrc/quramcore/wink_jpeg_enc_adv.c \
    jni/qfrc/quramcore/wink_jpeg_enc_mcu.c \
    jni/qfrc/quramcore/wink_jpeg_enc_util.c \
    jni/qfrc/quramcore/csc_converter.c \
    jni/qfrc/quramcore/wink_jpeg_enc_exif_creator.c \
    jni/qfrc/quramcore/QuramWinkDecInfo.c \
    jni/qfrc/quramcore/WINKJ_DecLib_Color.c \
    jni/qfrc/quramcore/WINKJ_DecLib_Red.c \
    jni/qfrc/quramcore/qresize.c \
    jni/qfrc/quramcore/qrcms.cpp \
    jni/qfrc/quramcore/QImage.cpp \
    jni/qfrc/quramcore/ColorFormatUtil.cpp \
    jni/qfrc/quramcore/QfrcME.cpp \
    jni/qfrc/quramcore/QfrcSnap.cpp \
    jni/qfrc/quramcore/QfrcComplexity.cpp \
    jni/qfrc/quramcore/QfrcManager.cpp \
    jni/qfrc/quramcore/QfrcIIP.cpp \
    jni/qfrc/quramcore/QfrcIPCL.cpp \
    jni/qfrc/quramcore/OpenCLWrapper.cpp \
    jni/qfrc/quramcore/QfrcJob.cpp \
    jni/qfrc/quramcore/QfrcMCSR.cpp \
    jni/qfrc/quramcore/QFRCNative.cpp \
    jni/qfrc/quramcore/QfrcFD.cpp \
    jni/qfrc/quramcore/QMediaEncoder.cpp \
    jni/qfrc/quramcore/QMediaDecoder.cpp \
    jni/qfrc/quramcore/QUtils.cpp \
    jni/qfrc/quramcore/RawFileDecoder.cpp \
    jni/qfrc/quramcore/image_util.cpp \
    jni/qfrc/quramcore/main_ondemand.cpp \
    jni/qfrc/quramcore/AIFRC.cpp \
    jni/qfrc/quramcore/QfrcMCSR.cpp \
    jni/qfrc/quramcore/QfrcFD.cpp \
    jni/qfrc/quramcore/QfrcJob.cpp \
    jni/qfrc/quramcore/QfrcME.cpp \
    jni/qfrc/quramcore/QfrcSnap.cpp \
    jni/qfrc/quramcore/QfrcComplexity.cpp \
    jni/qfrc/quramcore/QfrcManager.cpp \
    jni/qfrc/quramcore/QfrcIIP.cpp \
    jni/qfrc/quramcore/QFRCNative.cpp \
    jni/qfrc/quramcore/QMediaEncoder.cpp \
    jni/qfrc/quramcore/QMediaDecoder.cpp \
    jni/qfrc/quramcore/QUtils.cpp \
    jni/qfrc/quramcore/RawFileDecoder.cpp \
    jni/qfrc/quramcore/image_util.cpp \
    jni/qfrc/quramcore/main_ondemand.cpp \
    jni/qfrc/quramcore/AIFRC.cpp

LOCAL_C_INCLUDES := \
    jni/qfrc/quramcore \
    jni/qfrc/quramcore/include \
    jni/qfrc/quramcore/include/opencv \
    jni/qfrc/quramcore/include/opencv2

LOCAL_LDLIBS := -llog -landroid -lOpenCL

include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := aifrc
LOCAL_SRC_FILES := \
    jni/qfrc/tests/main_test.cpp

LOCAL_C_INCLUDES := \
    jni/qfrc/quramcore \
    jni/qfrc/quramcore/include \
    jni/qfrc/quramcore/include/opencv \
    jni/qfrc/quramcore/include/opencv2

LOCAL_SHARED_LIBRARIES := quramcore

include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := video_transcoder
LOCAL_SRC_FILES := \
    jni/qfrc/tests/main_test.cpp

LOCAL_C_INCLUDES := \
    jni/qfrc/quramcore \
    jni/qfrc/quramcore/include \
    jni/qfrc/quramcore/include/opencv \
    jni/qfrc/quramcore/include/opencv2

LOCAL_SHARED_LIBRARIES := quramcore

include $(BUILD_EXECUTABLE)

