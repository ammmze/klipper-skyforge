#!/usr/bin/env bash

# Usage:
# $ bash ~/printer_data/config/flash/katapult/update-all.sh [mcu's to update]
#
# Example:
# $ bash ~/printer_data/config/flash/katapult/update-all.sh m8p_v2 sb2209

MCU_MAIN=m8p_v2
MCU_TOOLHEAD=sb2209
MCU_AFC=afc_lite_1.0
MCUS="$@"

if [ -z "${MCUS}" ]; then
  echo "Please specify the MCU's to update. For example:"
  echo "$0 ${MCU_MAIN} ${MCU_TOOLHEAD}"
  exit 1
fi

function build {
  local mcu="$1"
  local label="$2"
  local config="${mcu}.config"
  touch ~/printer_data/config/flash/katapult/"${config}"
  ln -sf ~/printer_data/config/flash/katapult/"${config}" "${config}"
  make clean KCONFIG_CONFIG="${config}"
  make menuconfig KCONFIG_CONFIG="${config}"
  make -j "$(nproc --all)" KCONFIG_CONFIG="${config}"
  read -p "${label} bootloader built, please check above for any errors. Press [Enter] to continue flashing, or [Ctrl+C] to abort"
}

function update_m8p_v2 {
  build m8p_v2 'Manta M8P v2.0'
  
  # TODO: Flash out/katapult.bin
  # sudo dfu-util --list
  # Found DFU: [0483:df11] ver=0200, devnum=4, cfg=1, intf=0, path="5-1.4", alt=1, name="@Option Bytes   /0x5200201C/01*88 e", serial="3560376F3431"
  # Found DFU: [0483:df11] ver=0200, devnum=4, cfg=1, intf=0, path="5-1.4", alt=0, name="@Internal Flash   /0x08000000/8*128Kg", serial="3560376F3431"
  
  while ! sudo dfu-util --list | grep -s '\[0483:df11\]'; do # TODO: Verify serial?
    read -p 'Manta M8P needs to be in DFU mode. Please hold Boot0 and press reset to enter DFU mode. Press [Enter] to try again, or [Ctrl+C] to abort'
  done
  sudo dfu-util -a 0 -D ~/katapult/out/katapult.bin --dfuse-address 0x08000000:force:leave -d 0483:df11
}

function update_sb2209 {
  build sb2209 'SB2209'
  
  while ! lsusb | grep -s '2e8a:0003'; do
    read -p 'SB2209 needs to be in Boot mode. Please hold Boot and press reset to enter Boot mode. Press [Enter] to try again, or [Ctrl+C] to abort'
  done
  make flash KCONFIG_CONFIG=sb2209.config FLASH_DEVICE=2e8a:0003
}

sudo service klipper stop
cd ~/katapult
git pull

for mcu in ${MCUS}; do
  echo "doing mcu ${mcu}"
  case "$mcu" in
    m8p_v2)
      update_m8p_v2
      ;;
    sb2209)
      update_sb2209
      ;;
  esac
done


# ./scripts/flash-sdcard.sh /dev/ttyAMA0 fysetc-spider-v1
# read -p "Spider firmware flashed, please check above for any errors. Press [Enter] to continue, or [Ctrl+C] to abort"

# make clean KCONFIG_CONFIG=config.rpi
# make menuconfig KCONFIG_CONFIG=config.rpi

# make KCONFIG_CONFIG=config.rpi
# read -p "RPi firmware built, please check above for any errors. Press [Enter] to continue flashing, or [Ctrl+C] to abort"
# make flash KCONFIG_CONFIG=config.rpi

sudo service klipper start
