#!/bin/bash

# NDK 경로 설정
#export ANDROID_NDK_ROOT=~/Android/ndk/android-ndk-r27
#export ANDROID_NDK_ROOT=~/qfrc/android-ndk-r27b
#export PATH=$ANDROID_NDK_ROOT:$PATH

if [ -z "$ANDROID_NDK_ROOT" ] || [ -z "$SNPE_ROOT" ]; then
    echo "Environment not set!"
    echo "run the command below:"
    echo "source /ext/snpe/envset.sh"
    exit
fi

TARGET_DEVICE=$1
TARGET_NPU_BACKEND=$2
INCLUDE_MODEL=$3
AIFRC_PACKAGE=$4
USE_IDL=$5
USE_SRMC=$6
HWASAN=$7

# for convinient usage. append "-s " if not exists.
if [ ! -z "$TARGET_DEVICE" ] && [[ "$TARGET_DEVICE" != "-s "* ]]; then
    TARGET_DEVICE="-s "$TARGET_DEVICE
fi

if [ -z "$TARGET_NPU_BACKEND" ]; then
    TARGET_NPU_BACKEND="snap"
fi

# check SoC. snapdragon-qti. exynos-samsung.
SOC_MANUFACTURER=`adb ${TARGET_DEVICE} shell "getprop | grep -i ro.soc.manufacturer"`

if [[ "${SOC_MANUFACTURER,,}" == *"qti"* ]]; then
    SOC_MANUFACTURER="qti"
    SOC_MANUFACTURER_ID="0"
elif [[ "${SOC_MANUFACTURER,,}" == *"samsung"* ]]; then
    SOC_MANUFACTURER="samsung"
    SOC_MANUFACTURER_ID="1"
elif [[ "${SOC_MANUFACTURER,,}" == *"mediatek"* ]]; then
    SOC_MANUFACTURER="mediatek"
    SOC_MANUFACTURER_ID="2"
else
    #just build test
    SOC_MANUFACTURER="qti"
    SOC_MANUFACTURER_ID="0"
fi

echo; echo "Build for" $SOC_MANUFACTURER "using" $TARGET_NPU_BACKEND; echo


# check Snap IDLTYPE dependacies
hidl_name=`adb $TARGET_DEVICE shell ls /system/lib64/libsnap_hidl.snap.samsung.so`

if [ ! -z $hidl_name ] && [ $hidl_name == "/system/lib64/libsnap_hidl.snap.samsung.so" ]; then
    BUILD_DEP_LIBS=("/vendor/lib64/libOpenCL.so" "/vendor/lib64/libsnap_vndk.so" "/system/lib64/libsnap_hidl.snap.samsung.so" "/system/lib64/libc++.so")
    IDLTYPE="hidl"
else
    BUILD_DEP_LIBS=("/vendor/lib64/libOpenCL.so" "/vendor/lib64/libsnap_vndk.so" "/system/lib64/libsnap_aidl.snap.samsung.so" "/system/lib64/libc++.so")
    IDLTYPE="aidl"
fi


[ ! -d jni/qfrc/libs ] && mkdir -p jni/qfrc/libs

for idx in ${!BUILD_DEP_LIBS[*]} ; do

    target_lib=${BUILD_DEP_LIBS[$idx]}
    host_lib="jni/qfrc/libs/${target_lib##*/}"

    echo "check library : "$host_lib

    md5sum_host=`md5sum $host_lib`
    md5sum_target=`adb $TARGET_DEVICE shell "md5sum ${target_lib}"`

    if [ "${md5sum_host:0:32}" != "${md5sum_target:0:32}" ]; then 
        result=`adb $TARGET_DEVICE pull $target_lib $host_lib`
        echo "  "$host_lib "does not match." $result
    fi
done

if [[ "${TARGET_NPU_BACKEND}" == "snpe" ]]; then 
    adb $TARGET_DEVICE pull /system/vendor/lib64/libSNPE.so jni/qfrc/libs/libSNPE.so
elif [[ "${TARGET_NPU_BACKEND}" == "snpe2" ]]; then 
    adb $TARGET_DEVICE pull /system/vendor/lib64/libSNPE.so jni/qfrc/libs/libSNPE.so
fi
echo

# build

export SNPE_TARGET_ARCH=aarch64-android-clang8.0

if [ -z $HWASAN ] || [ $HWASAN == 0 ]; then
    if [ -z $USE_IDL ] || [ $USE_IDL == 0 ]; then
        export APP_BUILD_FLAGS="APP_STL=none"
    else
        export APP_BUILD_FLAGS="APP_STL=c++_static"
    fi
else
    # cannot test current target. need binary for sanitizing
    export APP_BUILD_FLAGS="APP_ABI=arm64-v8a \
        APP_STL=c++_static \
        APP_CPPFLAGS=-std=c++17 \
        APP_CPPFLAGS+=-fexceptions \
        APP_CPPFLAGS+=-frtti \
        APP_CPPFLAGS+=-fsanitize=hwaddress \
        APP_CPPFLAGS+=-fno-omit-frame-pointer \
        APP_LDFLAGS=-fsanitize=hwaddress"
fi
echo APP_BUILD_FLAGS : $APP_BUILD_FLAGS

ndk-build -B -j8 \
    NDK_TOOLCHAIN_VERSION=clang \
    TARGET_DEVICE=$SOC_MANUFACTURER \
    TARGET_DEVICE_ID=$SOC_MANUFACTURER_ID \
    TARGET_NPU_BACKEND=$TARGET_NPU_BACKEND \
    USE_IDL=$USE_IDL \
    IDLTYPE=$IDLTYPE \
    INCLUDE_MODEL=$INCLUDE_MODEL \
    AIFRC_PACKAGE=$AIFRC_PACKAGE \
    HWASAN=$HWASAN \
    USE_SRMC=$USE_SRMC \
    $APP_BUILD_FLAGS

echo  ndk-build -j8 \
    NDK_TOOLCHAIN_VERSION=clang \
    TARGET_DEVICE=$SOC_MANUFACTURER \
    TARGET_DEVICE_ID=$SOC_MANUFACTURER_ID \
    TARGET_NPU_BACKEND=$TARGET_NPU_BACKEND \
    USE_IDL=$USE_IDL \
    IDLTYPE=$IDLTYPE \
    INCLUDE_MODEL=$INCLUDE_MODEL \
    AIFRC_PACKAGE=$AIFRC_PACKAGE \
    HWASAN=$HWASAN \
    USE_SRMC=$USE_SRMC \
    $APP_BUILD_FLAGS

# ndk-build -j8 \
#     NDK_TOOLCHAIN_VERSION=clang \
#     APP_ABI=arm64-v8a \
#     APP_STL=c++_shared \
#     APP_CFLAGS="-fexceptions -frtti -fsanitize=hwaddress -fno-omit-frame-pointer" \
#     APP_LDFLAGS="-fsanitize=hwaddress" \
#     TARGET_DEVICE=$SOC_MANUFACTURER \
#     TARGET_DEVICE_ID=$SOC_MANUFACTURER_ID \
#     TARGET_NPU_BACKEND=$TARGET_NPU_BACKEND \
#     IDLTYPE=$IDLTYPE


