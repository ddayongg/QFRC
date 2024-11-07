#!/bin/bash

TARGET_DEVICE=$1
ENFORCE=${2:-1}
SILENT=${3:-0}

ENFORCE=0

if [ ! -z "$TARGET_DEVICE" ]; then
#----------------------------------------------edited
    # USB 연결일 경우 IP 주소 변환 생략
    if [[ "$TARGET_DEVICE" == "usb" || "$TARGET_DEVICE" =~ ^[A-Za-z0-9]+$ ]]; then
        echo "Using USB connection with target device: $TARGET_DEVICE"
        ADB_DEVICE="-s $TARGET_DEVICE"
    else
        # IP 주소 기반 장치 처리
        if [ "$TARGET_DEVICE" != "192.168.0."* ]; then
            TARGET_DEVICE="192.168.0."$TARGET_DEVICE
        fi
        if [ "$TARGET_DEVICE" != *":5555" ]; then
            TARGET_DEVICE=$TARGET_DEVICE":5555"
        fi
        ADB_DEVICE="-s $TARGET_DEVICE"
        adb_res=$(adb connect $TARGET_DEVICE 2>&1)
        if [[ "$adb_res" == "failed"* ]]; then
            echo "Booting failed - ADB connecting $TARGET_DEVICE failed."
            exit
        else
            if [ $SILENT == 0 ]; then
                echo "ADB connection success."
            fi
        fi
    fi
#-----------------------------------------------------edited    

    # ADB 루트 권한 요청
    adb_res=$(adb $ADB_DEVICE root 2>&1)
    if [[ "$adb_res" != "restarting"* ]] && [[ "$adb_res" != *"already"* ]]; then
        echo "Booting failed - ADB rooting $TARGET_DEVICE failed."
        exit
    else
        if [ $SILENT == 0 ]; then
            echo "ADB root success."
        fi
    fi

    adb_res=$(adb $ADB_DEVICE remount 2>&1)
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
        adb_res=$(adb $ADB_DEVICE shell getenforce)
        # echo "adb shell getenforce : [$adb_res]"
        if [ "$adb_res" != "Permissive" ]; then
            if [ $SILENT == 0 ]; then
                echo "Enforce setting is not 0 - setting enforce to 0"
            fi
            adb $ADB_DEVICE shell setenforce 0
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
