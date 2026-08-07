#!/bin/sh

bus=$(grep -lF "NVIDIA i2c adapter 4 at 1:00.0" /sys/bus/i2c/devices/i2c-*/name)
bus=${bus#*/i2c-}
bus=${bus%/name}

current=$(ddcutil --bus "$bus" getvcp 60 --terse | awk '{print $4}')

if [ "$current" = "x0f" ]; then
    ddcutil --bus "$bus" setvcp 60 0x11
else
    ddcutil --bus "$bus" setvcp 60 0x0f
fi
