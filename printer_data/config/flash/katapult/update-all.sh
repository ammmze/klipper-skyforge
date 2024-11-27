#!/usr/bin/env bash

MCU_MAIN=m8p_v2
MCU_TOOLHEAD=sb2209
MCUS="$@"

if [ -z "${MCUS}" ]; then
  
  exit 1
fi

for mcu in "${MCUS}"; do
  echo "doing mcu ${mcu}"
done

exit

sudo service klipper stop
cd ~/katapult
git pull

export KCONFIG_CONFIG=m8p_v2.config
touch ~/printer_data/config/flash/katapult/"${KCONFIG_CONFIG}"
ln -sf ~/printer_data/config/flash/katapult/"${KCONFIG_CONFIG}" "${KCONFIG_CONFIG}"
make clean KCONFIG_CONFIG="${KCONFIG_CONFIG}"
make menuconfig KCONFIG_CONFIG="${KCONFIG_CONFIG}"
make -j "$(nproc --all)" KCONFIG_CONFIG="${KCONFIG_CONFIG}"
read -p "Manta M8P v2.0 bootloader built, please check above for any errors. Press [Enter] to continue flashing, or [Ctrl+C] to abort"

# TODO: Flash out/katapult.bin
# sudo dfu-util --list
# Found DFU: [0483:df11] ver=0200, devnum=4, cfg=1, intf=0, path="5-1.4", alt=1, name="@Option Bytes   /0x5200201C/01*88 e", serial="3560376F3431"
# Found DFU: [0483:df11] ver=0200, devnum=4, cfg=1, intf=0, path="5-1.4", alt=0, name="@Internal Flash   /0x08000000/8*128Kg", serial="3560376F3431"

while ! sudo dfu-util --list | grep -s '\[0483:df11\]'; do # TODO: Verify serial?
  read -p 'Manta M8P needs to be in DFU mode. Please hold Boot0 and press reset to enter DFU mode. Press [Enter] to try again, or [Ctrl+C] to abort'
done
sudo dfu-util -a 0 -D ~/katapult/out/katapult.bin --dfuse-address 0x08000000:force:leave -d 0483:df11
# ./scripts/flash-sdcard.sh /dev/ttyAMA0 fysetc-spider-v1
# read -p "Spider firmware flashed, please check above for any errors. Press [Enter] to continue, or [Ctrl+C] to abort"

# make clean KCONFIG_CONFIG=config.rpi
# make menuconfig KCONFIG_CONFIG=config.rpi

# make KCONFIG_CONFIG=config.rpi
# read -p "RPi firmware built, please check above for any errors. Press [Enter] to continue flashing, or [Ctrl+C] to abort"
# make flash KCONFIG_CONFIG=config.rpi

sudo service klipper start
