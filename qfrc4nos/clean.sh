#!/bin/bash

TARGET_DEVICE=$1

rm -rf jni/qfrc/libs
rm -rf libs
rm -rf obj
rm -rf release*

echo "Cleaning PC finished"

if [ ! -z "$TARGET_DEVICE" ]; then

    boot_res=$(./boot.sh $TARGET_DEVICE 1 1)
    # echo "boot_res : [$boot_res]"
    if [[ "$boot_res" == *"Booting failed"* ]]; then
        echo "Cleaning device failed - $boot_res"
        exit
    fi

    adb -s $TARGET_DEVICE shell rm -rf /data/local/tmp/qfrc4nos/

    echo "Cleaning $TARGET_DEVICE finished"

else
    echo "Cleaning device failed - target device not set"
fi
