#!/bin/bash

# Set a defaults - Override on CLI
: FCOS_DISK=${FCOS_DISK:=/dev/sdb}
: IGNITION_FILE=${IGNITION_FILE:=coreos-infra.ign}
: FIRMWARE_VERSION=${FIRMWARE_VERSION:=1.34}

FIRMWARE_URL=https://github.com/pftf/RPi4/releases/download/v${FIRMWARE_VERSION}
FIRMWARE_ZIP=RPi4_UEFI_Firmware_v${FIRMWARE_VERSION}.zip

# Install CoreOS onto the SD card
sudo coreos-installer install --stream stable --architecture aarch64 --platform metal \
     --ignition-file ${IGNITION_FILE} ${FCOS_DISK}

# Determine which partition will contain the EFI firmware files
EFIPART=$(lsblk $FCOS_DISK -J -oLABEL,PATH  |
	  jq -r '.blockdevices[] | select(.label == "EFI-SYSTEM")'.path)

# Retrieve the EFI Firmware zip file
curl --location --output /tmp/${FIRMWARE_ZIP} ${FIRMWARE_URL}/${FIRMWARE_ZIP}

# Extract the EFI firmware into the target partition
TMPDIR=$(mktemp --directory)
sudo mount ${EFIPART} ${TMPDIR}
sudo unzip -o /tmp/${FIRMWARE_ZIP} -d ${TMPDIR}

# Clean up
sudo umount ${TMPDIR}
rmdir ${TMPDIR}
rm /tmp/${FIRMWARE_ZIP}

