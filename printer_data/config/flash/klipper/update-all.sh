#!/usr/bin/env bash

sudo service klipper stop
cd ~/klipper
git pull

export KCONFIG_CONFIG=m8p_v2.config
touch ~/printer_data/config/flash/klipper/"${KCONFIG_CONFIG}"
ln -sf ~/printer_data/config/flash/klipper/"${KCONFIG_CONFIG}" "${KCONFIG_CONFIG}"
make clean KCONFIG_CONFIG="${KCONFIG_CONFIG}"
make menuconfig KCONFIG_CONFIG="${KCONFIG_CONFIG}"
make -j "$(nproc --all)" KCONFIG_CONFIG="${KCONFIG_CONFIG}"
read -p "Manta M8P v2.0 firmware built, please check above for any errors. Press [Enter] to continue flashing, or [Ctrl+C] to abort"

# sudo dfu-util -a 0 -d 0483:df11 --dfuse-address 0x08020000 -D ~/klipper/out/klipper.bin
# ./scripts/flash-sdcard.sh /dev/ttyAMA0 fysetc-spider-v1
# read -p "Spider firmware flashed, please check above for any errors. Press [Enter] to continue, or [Ctrl+C] to abort"

# make clean KCONFIG_CONFIG=config.rpi
# make menuconfig KCONFIG_CONFIG=config.rpi

# make KCONFIG_CONFIG=config.rpi
# read -p "RPi firmware built, please check above for any errors. Press [Enter] to continue flashing, or [Ctrl+C] to abort"
# make flash KCONFIG_CONFIG=config.rpi

sudo service klipper start
