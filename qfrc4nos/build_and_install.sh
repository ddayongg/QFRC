#!/bin/bash

if [ -z "$ANDROID_NDK_ROOT" ] || [ -z "$SNPE_ROOT" ]; then
    echo "Environment not set!"
    echo "run the command below:"
    echo "source /ext/snpe/envset.sh"
    exit
fi

TARGET_DEVICE=$1
TARGET_NPU_BACKEND=${2:-"snap"}
INCLUDE_MODEL=${3:-0}
AIFRC_PACKAGE=${4:-1}
USE_IDL=${5:-0}
USE_SRMC=${6:-1}

if [ -z "$TARGET_DEVICE" ]; then
    echo "build_and_install failed - target device not set"
    exit
fi

boot_res=$(./boot.sh $TARGET_DEVICE 1 1)
# echo "boot_res : [$boot_res]"
if [[ "$boot_res" == *"Booting failed"* ]]; then
    echo "build_and_install failed - $boot_res"
    exit
fi


# # add 192.168.0.
# if [ ! -z "$TARGET_DEVICE" ] && [[ "$TARGET_DEVICE" != "192.168.0."* ]]; then
#     TARGET_DEVICE="192.168.0."$TARGET_DEVICE
# fi
# # add :5555
# if [ ! -z "$TARGET_DEVICE" ] && [[ "$TARGET_DEVICE" != *":5555" ]]; then
#     TARGET_DEVICE=$TARGET_DEVICE":5555"
# fi

# add -s
if [ ! -z "$TARGET_DEVICE" ] && [[ "$TARGET_DEVICE" != "-s "* ]]; then
    TARGET_DEVICE="-s "$TARGET_DEVICE
fi

SOC_MANUFACTURER=`adb ${TARGET_DEVICE} shell "getprop | grep -i ro.soc.manufacturer"`
if [[ "${SOC_MANUFACTURER,,}" == *"qti"* ]]; then
    NPU_TYPE=0
elif [[ "${SOC_MANUFACTURER,,}" == *"samsung"* ]]; then
    NPU_TYPE=1
elif [[ "${SOC_MANUFACTURER,,}" == *"mediatek"* ]]; then
    NPU_TYPE=2
else
    echo "Unspecified SoC"
    exit
fi

if [ ! -z $AIFRC_PACKAGE ] && [ $AIFRC_PACKAGE == 1 ]; then
    PKGNAME=aifrc
    LIBNAME=libaifrc
else
    PKGNAME=qfrc
    LIBNAME=libfrc
fi


hidl_name=`adb $TARGET_DEVICE shell ls /system/lib64/libsnap_hidl.snap.samsung.so`
if [ ! -z $hidl_name ] && [ $hidl_name == "/system/lib64/libsnap_hidl.snap.samsung.so" ]; then
    IDLTYPE="hidl"
else
    IDLTYPE="aidl"
fi


# 0. Parse release directory name from device model, npu type, qfrc version, git version

SOC_NAME=`adb ${TARGET_DEVICE} shell "getprop | grep -i soc.model"`
SOC_NAME="${SOC_NAME##*[}"
SOC_NAME=${SOC_NAME/]/}
SOC_NAME=${SOC_NAME^^}
if [[ ! -z "${TARGET_NPU_BACKEND}" ]]; then 
    SOC_NAME="${SOC_NAME}_${TARGET_NPU_BACKEND}"
fi

GIT_VERSION=`git rev-parse --short=8 HEAD`

QFRC_VER_MAJOR=`cat jni/qfrc/QFRCNative.hpp | grep QFRC_VER_MAJOR`
QFRC_VER_MINOR=`cat jni/qfrc/QFRCNative.hpp | grep QFRC_VER_MINOR`
QFRC_VER_MICRO=`cat jni/qfrc/QFRCNative.hpp | grep QFRC_VER_MICRO`

QFRC_VER_MAJOR=${QFRC_VER_MAJOR%$'\r'}
QFRC_VER_MINOR=${QFRC_VER_MINOR%$'\r'}
QFRC_VER_MICRO=${QFRC_VER_MICRO%$'\r'}

QFRC_VER_MAJOR=${QFRC_VER_MAJOR/"#define QFRC_VER_MAJOR "/}
QFRC_VER_MINOR=${QFRC_VER_MINOR/"#define QFRC_VER_MINOR "/}
QFRC_VER_MICRO=${QFRC_VER_MICRO/"#define QFRC_VER_MICRO "/}

INSTALL_ROOT="release_${PKGNAME}_v${QFRC_VER_MAJOR/ /}.${QFRC_VER_MINOR/ /}.${QFRC_VER_MICRO/ /}.${GIT_VERSION}"
INSTALL_SOC="${INSTALL_ROOT}/${SOC_NAME}"

if [[ "${SOC_NAME,,}" == *"sm8"* ]]; then 
    SNPE_VER=${SNPE_ROOT/\/ext\/snpe\//}
    INSTALL_SOC="${INSTALL_ROOT}/${SOC_NAME}_${SNPE_VER}"
fi


# 1. HWASAN library

rm -rf obj
rm -rf libs
bash build_arm_android.sh "$TARGET_DEVICE" snap $INCLUDE_MODEL $AIFRC_PACKAGE $USE_IDL $USE_SRMC 1

mkdir -p $INSTALL_SOC/libs/arm64-v8a-hwasan
cp libs/arm64-v8a/libmcaimegpu.samsung.so $INSTALL_SOC/libs/arm64-v8a-hwasan
if [ -z $USE_IDL ] || [ $USE_IDL == 0 ]; then
    cp libs/arm64-v8a/$LIBNAME.quram.so $INSTALL_SOC/libs/arm64-v8a-hwasan
else
    cp libs/arm64-v8a/$LIBNAME.$IDLTYPE.quram.so $INSTALL_SOC/libs/arm64-v8a-hwasan
fi

echo; echo "HWASAN Binaries are copied into $INSTALL_SOC"; echo;


# 2. Normal library

rm -rf obj
rm -rf libs
bash build_arm_android.sh "$TARGET_DEVICE" $TARGET_NPU_BACKEND $INCLUDE_MODEL $AIFRC_PACKAGE $USE_IDL $USE_SRMC 0

mkdir -p $INSTALL_SOC/include $INSTALL_SOC/assets $INSTALL_SOC/libs/arm64-v8a $INSTALL_SOC/libs/armeabi-v7a 
cp README.md $INSTALL_ROOT/

if [ ! -z $AIFRC_PACKAGE ] && [ $AIFRC_PACKAGE == 1 ]; then
    cp jni/qfrc/AIFRC.hpp $INSTALL_SOC/include
else
    cp jni/qfrc/QFRC.hpp $INSTALL_SOC/include
fi
cp jni/qfrc/QfrcCommon.hpp $INSTALL_SOC/include
cp jni/qfrc/QImage.hpp $INSTALL_SOC/include
cp jni/qfrc/QTypes.hpp $INSTALL_SOC/include
cp libs/arm64-v8a/libmcaimegpu.samsung.so $INSTALL_SOC/libs/arm64-v8a
if [ -z $USE_IDL ] || [ $USE_IDL == 0 ]; then
    cp libs/arm64-v8a/$LIBNAME.quram.so $INSTALL_SOC/libs/arm64-v8a
    cp libs/armeabi-v7a/$LIBNAME.quram.so $INSTALL_SOC/libs/armeabi-v7a
else
    cp libs/arm64-v8a/$LIBNAME.$IDLTYPE.quram.so $INSTALL_SOC/libs/arm64-v8a
    cp libs/armeabi-v7a/$LIBNAME.$IDLTYPE.quram.so $INSTALL_SOC/libs/armeabi-v7a
fi

echo; echo "Normal Binaries are copied into $INSTALL_SOC"; echo;

# 3. Model files
if [ ${NPU_TYPE} == 0 ]; then      # Qualcomm

    # # ref-27700    
    # if [[ "${SNPE_ROOT,,}" == *"2.4"* ]]; then
    #     MODELFILE="qfrc_6_0_s12_0_v2_e27700_snpe2.4.3.3958_fp16_cached.dlc"
    # elif [[ "${SNPE_ROOT,,}" == *"2.7"* ]]; then 
    #     MODELFILE="qfrc_6_0_s12_0_v2_e27700_snpe2.7.0.4264_fp16_cached.dlc"
    # else
    #     MODELFILE="qfrc_6_0_s12_0_v2_e27700_snpe2.4.3.3958_fp16_cached.dlc"
    # fi

    # # ref-32700
    # if [[ "${SNPE_ROOT,,}" == *"2.4"* ]]; then
    #     MODELFILE="QFNet_Ref_block_e32700_snpe2.4.3.3958_fp16_cached.dlc"
    # elif [[ "${SNPE_ROOT,,}" == *"2.16"* ]]; then
    #     MODELFILE="QFNet_Ref_block_e32700_snpe2.16.0.231029_fp16_cached.dlc"
    # else
    #     MODELFILE="QFNet_Ref_block_e32700_snpe2.4.3.3958_fp16_cached.dlc"
    # fi
    
    # # ref-34600
    # SOC_MODEL=`adb ${TARGET_DEVICE} shell "getprop | grep -i ro.soc.model"`
    # if [[ "${SOC_MODEL}" == *"SM8550"* ]]; then
    #     MODELFILE="QFNet_Ref_block_e34660_snpe2.10.0.4541_fp16_cached.dlc"
    # else
    #     MODELFILE="QFNet_Ref_block_e34660_snpe2.16.0.231029_fp16_cached.dlc"
    # fi
    
    # ref-38500
    SOC_MODEL=`adb ${TARGET_DEVICE} shell "getprop | grep -i ro.soc.model"`
    if [[ "${SOC_MODEL}" == *"SM8550"* ]]; then
        MODELFILE="QFNet_Ref_e38500_snpe2.10.0.4541_tf16_sm8550_cached.dlc"
    else
        MODELFILE="QFNet_Ref_e38500_snpe2.18.0.240101_tf16_sm8650_cached.dlc"
    fi

    # # ref-c128-4950
    # if [[ "${SNPE_ROOT,,}" == *"2.4"* ]]; then
    #     MODELFILE="QFNet_Ref_c128_block_e4950_snpe2.4.3.3958_fp16_cached.dlc"
    # elif [[ "${SNPE_ROOT,,}" == *"2.16"* ]]; then
    #     MODELFILE="QFNet_Ref_c128_block_e4950_snpe2.16.0.231029_fp16_cached.dlc"
    # else
    #     MODELFILE="QFNet_Ref_c128_block_e4950_snpe2.4.3.3958_fp16_cached.dlc"
    # fi
    
    # failure decision model        
    FD_MODELFILE="fd_B1_v1_aug_e00500_snpe2.16.0.231029_fp16_cached.dlc"

    MODELFILE_DST=${PKGNAME}.dlc
    FD_MODELFILE_DST=${PKGNAME}_fd.dlc

elif [ ${NPU_TYPE} == 1 ]; then   # LSI

    MODELFILE="QFNet_Ref_block_e34660_LSI_a16w8.nnc"
    FD_MODELFILE="fd_B1_v1_aug_e00500_LSI_a16w8.nnc"

    MODELFILE_DST=${PKGNAME}.nnc
    FD_MODELFILE_DST=${PKGNAME}_fd.nnc

elif [ ${NPU_TYPE} == 2 ]; then   # MediaTek

    echo "MediaTek currently uses Samsung's model file, so pushing models will be skipped."

fi

MODELFILE=assets/${MODELFILE}
if [ -f "$MODELFILE" ]; then
    if [ -z $INCLUDE_MODEL ] || [ $INCLUDE_MODEL != 1 ]; then 
        MODELFILE_DST=$INSTALL_SOC/assets/${MODELFILE_DST}
        cp $MODELFILE $MODELFILE_DST 
    else
        # Since model file was added inside source code (QfrcModels.cpp),
        # We don't need to add .dlc file into release folder.
        echo "Model data is already included in the library, skip pushing .dlc files."
    fi
fi

FD_MODELFILE=assets/${FD_MODELFILE}
if [ -f "$MODELFILE" ]; then
    FD_MODELFILE_DST=$INSTALL_SOC/assets/${FD_MODELFILE_DST}
    cp $FD_MODELFILE $FD_MODELFILE_DST
fi

tree $INSTALL_SOC

exit


