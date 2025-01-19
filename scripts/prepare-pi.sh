#!/bin/bash

# Set a default target disk
: FCOS_DISK=${FCOS_DISK:=/dev/sdb}
: IGNITION_FILE=${IGNITION_FILE:=coreos-infra.ign}
: FIRMWARE_VERSION=${FIRMWARE_VERSION:=1.34}

FIRMWARE_URL=https://github.com/pftf/RPi4/releases/download/v${FIRMWARE_VERSION}
FIRMWARE_ZIP=RPi4_UEFI_Firmware_v${FIRMWARE_VERSION}.zip

sudo coreos-installer install --stream stable --architecture aarch64 --platform rpi4 \
     --ignition-file ${IGNITION_FILE} ${FCOS_DISK}

EFIPART=$(lsblk $FCOS_DISK -J -oLABEL,PATH  |
	  jq -r '.blockdevices[] | select(.label == "EFI-SYSTEM")'.path)

TMPDIR=$(mktemp --directory)

sudo mount ${EFIPART} ${TMPDIR}
curl --location --output /tmp/${FIRMWARE_ZIP} ${FIRMWARE_URL}/${FIRMWARE_ZIP}
sudo unzip -o /tmp/${FIRMWARE_ZIP} -d ${TMPDIR}
sudo umount ${TMPDIR}
rmdir ${TMPDIR}
rm /tmp/${FIRMWARE_ZIP}

