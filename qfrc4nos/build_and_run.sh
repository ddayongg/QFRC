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
HWASAN=${7:-0}

DEVICE_ROOT=/data/local/tmp/qfrc4nos
RUN_UNIT_TEST=false


if [ -z "$TARGET_DEVICE" ]; then
    echo "build_and_run failed - target device not set"
    exit
fi

# Booting target device
boot_res=$(./boot.sh $TARGET_DEVICE 1 1)
if [[ "$boot_res" == *"Booting failed"* ]]; then
    echo "build_and_run failed - $boot_res"
    exit
fi

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


bash build_arm_android.sh "$TARGET_DEVICE" $TARGET_NPU_BACKEND $INCLUDE_MODEL $AIFRC_PACKAGE $USE_IDL $USE_SRMC $HWASAN

# stage 2. run 

# stage 2-1. prepare libs and bins

adb $TARGET_DEVICE shell "rm -r ${DEVICE_ROOT}/output"
adb $TARGET_DEVICE shell "mkdir -p ${DEVICE_ROOT}/assets; mkdir -p ${DEVICE_ROOT}/output; "
adb $TARGET_DEVICE push libs/arm64-v8a $DEVICE_ROOT
adb $TARGET_DEVICE push libs/armeabi-v7a $DEVICE_ROOT

adb $TARGET_DEVICE shell "rm -r ${DEVICE_ROOT}/../outdump"
adb $TARGET_DEVICE shell "mkdir -p ${DEVICE_ROOT}/../outdump"

# stage 2-2. run command

if [ ! -z $AIFRC_PACKAGE ] && [ $AIFRC_PACKAGE == 1 ]; then
    PKGNAME=aifrc
else
    PKGNAME=qfrc
fi

if [ ${NPU_TYPE} == 0 ]; then      # Qualcomm

    SOC_ID="0"

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
    
    if [ ! -z $INCLUDE_MODEL ] && [ $INCLUDE_MODEL == 2 ]; then
        MODELFILE_DST=${MODELFILE}
    else
        MODELFILE_DST=${PKGNAME}.dlc
    fi
    FD_MODELFILE_DST=${PKGNAME}_fd.dlc

elif [ ${NPU_TYPE} == 1 ]; then   # LSI

    SOC_ID="1"
    MODELFILE="QFNet_Ref_block_e34660_LSI_a16w8.nnc"
    FD_MODELFILE="fd_B1_v1_aug_e00500_LSI_a16w8.nnc"
    
    if [ ! -z $INCLUDE_MODEL ] && [ $INCLUDE_MODEL == 2 ]; then
        MODELFILE_DST=${MODELFILE}
    else
        MODELFILE_DST=${PKGNAME}.nnc
    fi
    FD_MODELFILE_DST=${PKGNAME}_fd.nnc
    
elif [ ${NPU_TYPE} == 2 ]; then   # MediaTek

    echo "MediaTek currently uses Samsung's model file, so pushing models will be skipped."

fi

MODELFILE=assets/${MODELFILE}
MODELFILE_DST=assets/${MODELFILE_DST}
FD_MODELFILE=assets/${FD_MODELFILE}
FD_MODELFILE_DST=assets/${FD_MODELFILE_DST}

echo MODELFILE ${MODELFILE}
if [ -z $INCLUDE_MODEL ] || [ $INCLUDE_MODEL != 1 ]; then
    md5sum_tobe=`md5sum ${MODELFILE}`
    md5sum_asis=`adb $TARGET_DEVICE shell "md5sum ${DEVICE_ROOT}/${MODELFILE_DST}"`
    if [ "${md5sum_tobe:0:32}" != "${md5sum_asis:0:32}" ]; then 
        echo "Model file is different. Pushing model file..."
        adb $TARGET_DEVICE push ${MODELFILE} ${DEVICE_ROOT}/${MODELFILE_DST}
    else
        echo "Model file already exists at ${DEVICE_ROOT}"
    fi
else
    echo "Model file is included in the library, skip pushing .dlc files."
fi

echo FD_MODELFILE ${FD_MODELFILE}
md5sum_tobe=`md5sum ${FD_MODELFILE}`
md5sum_asis=`adb $TARGET_DEVICE shell "md5sum ${DEVICE_ROOT}/${FD_MODELFILE_DST}"`
if [ "${md5sum_tobe:0:32}" != "${md5sum_asis:0:32}" ]; then 
    echo "FD Model file is different. Pushing FD model file..."
    adb $TARGET_DEVICE push ${FD_MODELFILE} ${DEVICE_ROOT}/${FD_MODELFILE_DST}
else
    echo "FD model file already exists at ${DEVICE_ROOT}"
fi


if [[ "${RUN_UNIT_TEST}" == "false" ]]; then
    currentDataTime=`date +"%Y%m%d_%H%M%S"`
    test_folder=atest
    isP010raw=0
    # test_folder=hdr10raw
    # isP010raw=1
    if [ -z $isP010raw ] || [ $isP010raw != 1 ]; then
        extension='mp4'
    else
        extension='yuv'
    fi
    for file in ${test_folder}/*; do

        filename=$(basename "$file")    # Get the base name of the file without the path
        filename=${filename###}         # Remove any leading '#' character if present
        filename="${filename%.*}"       # Remove the file extension (e.g., .jpg, .png) if it exists

        if [ -z $isP010raw ] || [ $isP010raw != 1 ]; then
            video_info=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$file")
            IFS='x' read -r width height <<< "$video_info"
        
            # if [ ${width} == 1080 ]; then
            #     echo rotating "$file"...
            #     ffmpeg -i "$file" -vf "transpose=1" -metadata:s:v rotate=0 -c:a copy -y -v quiet ffmpeg_temp.mp4
            #     exiftool -rotation=270 ffmpeg_temp.mp4
            #     rm "$file"
            #     mv ffmpeg_temp.mp4 "$file"
            #     video_info=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$file")
            #     IFS='x' read -r width height <<< "$video_info"
            # fi
        fi

        TEST_FILE=${filename}
        WIDTH=${width}
        HEIGHT=${height}

        echo ${TEST_FILE}"  "${WIDTH}"  "${HEIGHT}

        # # TEST_FILE="5MountainsHiddenValleyGCKimJongHyukProHyukProSwingCollection"
        # WIDTH=1920
        # HEIGHT=1088
        
        # Pushing video file into device
        VIDEO_SRC=${test_folder}/${TEST_FILE}.${extension}
        VIDEO_DST=${DEVICE_ROOT}/assets/${TEST_FILE}.${extension}
        md5sum_tobe=`md5sum ${VIDEO_SRC}`
        md5sum_asis=`adb $TARGET_DEVICE shell "md5sum ${VIDEO_DST}"`
        if [ "${md5sum_tobe:0:32}" != "${md5sum_asis:0:32}" ]; then 
            echo 'Pushing '${VIDEO_SRC}'...'
            adb $TARGET_DEVICE push ${VIDEO_SRC} ${VIDEO_DST}
        fi

        MAXTHREAD=4
        REPEAT=1
        ENCODING=1
        FRAMES=100
        if [ -z $isP010raw ] || [ $isP010raw != 1 ]; then
            FORMAT=1    # 0 for NV12, 8 for P010
        else
            FORMAT=8
        fi
        UPSAMPLE=4
        NPU_BACKEND=0   # 0 for snap, 2 for snpe
        if [[ "${SOC_MANUFACTURER,,}" == *"samsung"* ]]; then   # if LSI, fix NPU_BACKEND to 3 (QNpuType::NPU_EDEN)
            NPU_BACKEND=3
        fi
        QUANT_TYPE=0     # 0 for float, 1 for INT8    

        TARGET_CMD="cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/video_transcoder"

        if [ ! -z $INCLUDE_MODEL ] && [ $INCLUDE_MODEL == 2 ]; then
            ARG_MODELPATH="-m ${MODELFILE}"
        else
            ARG_MODELPATH="-m assets"
        fi

        # ARG_VIDEO="-i assets/${TEST_FILE}.mp4 -o output/${TEST_FILE}_x${UPSAMPLE}.mp4"
        ARG_VIDEO="-i assets/${TEST_FILE}.${extension} -o output/${TEST_FILE}_x${UPSAMPLE}.mp4"
        ARG_MISC="-j ${MAXTHREAD} -w ${WIDTH} -h ${HEIGHT} -b 10000000 -t ${SOC_ID} -r ${REPEAT} -e ${ENCODING} -f ${FRAMES} -u ${UPSAMPLE} -a ${FORMAT}"
        ARG_NPU="-n ${NPU_BACKEND} -q ${QUANT_TYPE}"
        
        echo; echo "adb command :"
        echo ${TARGET_CMD} ${ARG_MODELPATH} ${ARG_MISC} ${ARG_NPU} ${ARG_VIDEO}
        echo
         
        adb $TARGET_DEVICE logcat -c

        adb $TARGET_DEVICE shell "${TARGET_CMD} ${ARG_MODELPATH} ${ARG_VIDEO} ${ARG_MISC} ${ARG_NPU}"

        mkdir -p lastdump/${currentDataTime}
        # rm lastdump/lastdump*
        adb $TARGET_DEVICE logcat -d > lastdump/${currentDataTime}/${TEST_FILE}.txt

        # break
        # sleep 10
    done

    if [ ! -z $INCLUDE_MODEL ] && [ $INCLUDE_MODEL == 2 ]; then
        adb $TARGET_DEVICE pull ${DEVICE_ROOT}/QfrcModels.hpp jni/qfrc/
        adb $TARGET_DEVICE pull ${DEVICE_ROOT}/QfrcModels.cpp jni/qfrc/
    else
        adb $TARGET_DEVICE pull ${DEVICE_ROOT}/output
    fi
    
    rm -rf outdump
    adb $TARGET_DEVICE pull ${DEVICE_ROOT}/../outdump

else
    # adb $TARGET_DEVICE shell "cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/testcases --gtest_output=xml:gtest_result.xml --gtest_repeat=1 --gtest_break_on_failure" # --gtest_shuffle" --gtest_break_on_failure  
    adb $TARGET_DEVICE push jni/tests/run_top.sh ${DEVICE_ROOT}/arm64-v8a/run_top.sh
    adb $TARGET_DEVICE shell "rm -rf ${DEVICE_ROOT}/top"
    adb $TARGET_DEVICE shell "mkdir -p ${DEVICE_ROOT}/top"
    adb $TARGET_DEVICE shell "chmod +x ${DEVICE_ROOT}/top"

    mkdir -p output/unitTest/top
    mkdir -p output/unitTest
    mkdir -p output/unitTest/logcat
    mkdir -p output/unitTest/log

    # -----------------------------------------------------------------------------------------------------------------------------------------------------------------
    # async qfrc_deinit all test
    # -----------------------------------------------------------------------------------------------------------------------------------------------------------------
    # adb $TARGET_DEVICE logcat -c 
    # adb $TARGET_DEVICE shell "cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/testcases --gtest_output=xml:gtest_Async_All.xml --gtest_repeat=1 --gtest_break_on_failure --gtest_shuffle --gtest_filter=qfrctest_future_async.*" > output/unitTest/log/000gtest_async_All.txt
    # adb $TARGET_DEVICE logcat -d  > output/unitTest/logcat/000gtest_async_All.txt
    
    # -----------------------------------------------------------------------------------------------------------------------------------------------------------------
    # async qfrc_deinit
    # -----------------------------------------------------------------------------------------------------------------------------------------------------------------
    # adb $TARGET_DEVICE logcat -c 
    # adb $TARGET_DEVICE shell "cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/testcases --gtest_repeat=100 --gtest_filter=qfrctest_future_async.Correct" > output/unitTest/log/00gtest_result_deinit_after_None.txt
    # adb $TARGET_DEVICE logcat -d  > output/unitTest/logcat/00_deinit_Correct.txt

    # adb $TARGET_DEVICE logcat -c 
    # adb $TARGET_DEVICE shell "cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/testcases --gtest_repeat=1500 --gtest_filter=qfrctest_future_async.insert_deinit_after_init" > output/unitTest/log/01gtest_result_deinit_after_init.txt
    # adb $TARGET_DEVICE logcat -d  > output/unitTest/logcat/01_deinit_after_init.txt

    adb $TARGET_DEVICE logcat -c 
    adb $TARGET_DEVICE shell "cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/testcases --gtest_repeat=100 --gtest_filter=qfrctest_future_async.insert_deinit_after_set" > output/unitTest/log/02gtest_result_deinit_after_set.txt
    adb $TARGET_DEVICE logcat -d > output/unitTest/logcat/02_deinit_after_set.txt

    # adb $TARGET_DEVICE logcat -c 
    # adb $TARGET_DEVICE shell "cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/testcases --gtest_repeat=1500 --gtest_filter=qfrctest_future_async.insert_deinit_after_releaseQImage" > output/unitTest/log/04gtest_result_deinit_after_releaseQImage.txt
    # adb $TARGET_DEVICE logcat -d  > output/unitTest/logcat/04_deinit_after_releaseQImage.txt
    
    adb $TARGET_DEVICE logcat -c 
    adb $TARGET_DEVICE shell "cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/testcases --gtest_repeat=100 --gtest_filter=qfrctest_future_async.insert_deinit_after_process" > output/unitTest/log/03gtest_result_deinit_after_process.txt
    adb $TARGET_DEVICE logcat -d  > output/unitTest/logcat/04_deinit_after_process.txt
    
    # adb $TARGET_DEVICE logcat -c 
    # adb $TARGET_DEVICE shell "cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/testcases --gtest_repeat=1500 --gtest_filter=qfrctest_future_async.insert_deinit_after_qfrc_finishInsertion" > output/unitTest/log/05gtest_result_deinit_after_finishInsertion.txt
    # adb $TARGET_DEVICE logcat -d  > output/unitTest/logcat/05_deinit_after_finishInsertion.txt
    # adb $TARGET_DEVICE logcat -c 

    # -----------------------------------------------------------------------------------------------------------------------------------------------------------------
    # async double qfrc_deinit
    # -----------------------------------------------------------------------------------------------------------------------------------------------------------------
    # adb $TARGET_DEVICE logcat -c 
    # adb $TARGET_DEVICE shell "cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/testcases --gtest_repeat=100 --gtest_filter=qfrctest_future_async.double_deinit_after_None" > output/unitTest/log/06gtest_result_double_deinit_after_None.txt
    # adb $TARGET_DEVICE logcat -d  > output/unitTest/logcat/06_double_deinit_Correct.txt

    # adb $TARGET_DEVICE logcat -c 
    # adb $TARGET_DEVICE shell "cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/testcases --gtest_repeat=1000 --gtest_filter=qfrctest_future_async.double_deinit_after_qfrc_init" > output/unitTest/log/07gtest_result_double_deinit_after_init.txt
    # adb $TARGET_DEVICE logcat -d  > output/unitTest/logcat/07_double_deinit_after_init.txt

    # adb $TARGET_DEVICE logcat -c 
    # adb $TARGET_DEVICE shell "cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/testcases --gtest_repeat=1000 --gtest_filter=qfrctest_future_async.double_deinit_after_qfrc_set" > output/unitTest/log/08gtest_result_double_deinit_after_set.txt
    # adb $TARGET_DEVICE logcat -d  > output/unitTest/logcat/08_double_deinit_after_set.txt

    # adb $TARGET_DEVICE logcat -c 
    # adb $TARGET_DEVICE shell "cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/testcases --gtest_repeat=1000 --gtest_filter=qfrctest_future_async.double_deinit_after_qfrc_releaseQImage" > output/unitTest/log/10gtest_result_double_deinit_after_releaseQImage.txt
    # adb $TARGET_DEVICE logcat -d  > output/unitTest/logcat/10_double_deinit_after_releaseQImage.txt

    # adb $TARGET_DEVICE logcat -c 
    # adb $TARGET_DEVICE shell "cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/testcases --gtest_repeat=1000 --gtest_filter=qfrctest_future_async.double_deinit_after_qfrc_finishInsertion" > output/unitTest/log/11gtest_result_double_deinit_after_finishInsertion.txt
    # adb $TARGET_DEVICE logcat -d  > output/unitTest/logcat/11_double_deinit_after_finishInsertion.txt
    
    # -----------------------------------------------------------------------------------------------------------------------------------------------------------------
    # sync qfrc_deinit
    # -----------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    # adb $TARGET_DEVICE logcat -c 
    # adb $TARGET_DEVICE shell "cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/testcases --gtest_repeat=100 --gtest_filter=qfrctest_sync.Correct" > output/unitTest/log/12gtest_result_sync_Correct.txt
    # adb $TARGET_DEVICE logcat -d  > output/unitTest/logcat/12gtest_result_sync_Correct.txt

    # adb $TARGET_DEVICE logcat -c 
    # adb $TARGET_DEVICE shell "cd ${DEVICE_ROOT} && LD_LIBRARY_PATH=${DEVICE_ROOT}/arm64-v8a ./arm64-v8a/testcases --gtest_repeat=100 --gtest_filter=qfrctest_sync.random_insert_deinit" > output/unitTest/log/13gtest_result_sync_random_deinit.txt
    # adb $TARGET_DEVICE logcat -d  > output/unitTest/logcat/13gtest_result_sync_random_deinit.txt

    # -----------------------------------------------------------------------------------------------------------------------------------------------------------------
    # pull memUsage(top)
    # -----------------------------------------------------------------------------------------------------------------------------------------------------------------
    adb $TARGET_DEVICE pull ${DEVICE_ROOT}/top output/unitTest
fi
