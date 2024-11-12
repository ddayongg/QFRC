#!/bin/bash

TARGET_DEVICE=$1
ENFORCE=${2:-1}
SILENT=${3:-0}

ENFORCE=0

if [ ! -z "$TARGET_DEVICE" ]; then

    

    adb_res=$(adb connect $TARGET_DEVICE 2>&1)
    # echo "adb connect : [$adb_res]"
    if [[ "$adb_res" == "failed"* ]]; then
        echo "Booting failed - ADB connecting $TARGET_DEVICE failed."
        exit
    else
        if [ $SILENT == 0 ]; then
            echo "ADB connection success."
        fi
    fi

    adb_res=$(adb -s $TARGET_DEVICE root 2>&1)
    # echo "adb root : [$adb_res]"
    if [[ "$adb_res" != "restarting"* ]] && [[ "$adb_res" != *"already"* ]]; then
        echo "Booting failed - ADB rooting $TARGET_DEVICE failed."
        exit
    else
        if [ $SILENT == 0 ]; then
            echo "ADB root success."
        fi
    fi
    
    adb_res=$(adb -s $TARGET_DEVICE remount 2>&1)
    if [[ "$adb_res" != *"emount succeeded"* ]]; then
        echo "adb remount : [$adb_res]"
        echo "Booting failed - ADB remounting $TARGET_DEVICE failed."
        # exit
    else
        if [ $SILENT == 0 ]; then
            echo "ADB remount success."
        fi
    fi

    if [ $ENFORCE == 1 ]; then
        adb_res=$(adb -s $TARGET_DEVICE shell getenforce)
        # echo "adb shell getenforce : [$adb_res]"
        if [ "$adb_res" != "Permissive" ]; then
            if [ $SILENT == 0 ]; then
                echo "Enforce setting is not 0 - setting enforce to 0"
            fi
            adb -s $TARGET_DEVICE shell setenforce 0
        else
            if [ $SILENT == 0 ]; then
                echo "Enforce setting is already 0"
            fi
        fi
    fi

    # adb -s $TARGET_DEVICE shell setprop secmm.mpp.frc.width 3840
    # adb -s $TARGET_DEVICE shell setprop secmm.mpp.frc.height 2160
    # adb -s $TARGET_DEVICE shell setprop secmm.mpp.frc.sample.factor 2
    # adb -s $TARGET_DEVICE shell setprop secmm.mpp.frc.fps 60

    echo "Booting $TARGET_DEVICE finished"

else
    echo "Booting failed - target device not set"
fi
