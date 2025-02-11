#!/bin/bash
# This script is adapted from 
# https://docs.fedoraproject.org/en-US/fedora-coreos/provisioning-raspberry-pi4
# EDK2: Combined Disk Mode Alternate Machine Disk Preparation

# USAGE: prepare-pi.sh <device path> [ignition file]

# Note the target device file
if [ $# -ge 1 ] ; then
    FCOS_DISK=$1
else
    echo "USAGE: prepare-pi.sh <device path [ignition file]"
    exit 1
fi

# Note the provided ignition file
[ $# -eq 2 ] && IGNITION_FILE=$2

# Defaults - Override by ENVVAR
: IGNITION_FILE=${IGNITION_FILE:=coreos-infra.ign}
: FIRMWARE_VERSION=${FIRMWARE_VERSION:=1.39}
: PI_VERSION=${PI_VERSION:=3}
FIRMWARE_URL=https://github.com/pftf/RPi${PI_VERSION}/releases/download/v${FIRMWARE_VERSION}
FIRMWARE_ZIP=RPi${PI_VERSION}_UEFI_Firmware_v${FIRMWARE_VERSION}.zip

# Install CoreOS onto the SD card
sudo coreos-installer install --stream stable --architecture aarch64 \
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

