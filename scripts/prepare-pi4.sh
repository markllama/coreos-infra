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
[ $# -ge 2 ] && IGNITION_FILE=$2
[ $# -eq 3 ] && IMAGE_PATH=$3

# Defaults - Override by ENVVAR
: IGNITION_FILE=${IGNITION_FILE:=coreos-infra.ign}
: FIRMWARE_VERSION=${FIRMWARE_VERSION:=1.40}

FIRMWARE_URL=https://github.com/pftf/RPi4/releases/download/v${FIRMWARE_VERSION}
FIRMWARE_ZIP=RPi4_UEFI_Firmware_v${FIRMWARE_VERSION}.zip

if [ -n "${IMAGE_PATH}" ] ; then
    IMAGE_SPEC="--image-file ${IMAGE_PATH}"
else
    IMAGE_SPEC="--stream stable --architecture aarch64"
fi

function main() {
    # Install CoreOS onto the SD card
    
    sudo coreos-installer install ${IMAGE_SPEC} \
      --ignition-file ${IGNITION_FILE} ${FCOS_DISK}

    # Determine which partition will contain the EFI firmware files
    #EFIPART=$(lsblk $FCOS_DISK -J -oLABEL,PATH  |
    #	  jq -r '.blockdevices[] | select(.label == "EFI-SYSTEM")'.path)
    EFIPART=$(efi_partition $FCOS_DISK)
    echo "EFI Partition: ${EFIPART}"
    # Retrieve the EFI Firmware zip file
    curl --location --output /tmp/${FIRMWARE_ZIP} ${FIRMWARE_URL}/${FIRMWARE_ZIP}

    # Extract the EFI firmware into the target partition
    TMPDIR=$(mktemp --directory)
    echo pausing 5 seconds ; sleep 5

    sudo mount ${EFIPART} ${TMPDIR} || exit 2
    
    sudo unzip -o /tmp/${FIRMWARE_ZIP} -d ${TMPDIR}

    # Clean up
    sudo umount ${TMPDIR}
    rmdir ${TMPDIR}
    rm /tmp/${FIRMWARE_ZIP}

}

function efi_partition() {
    local fcos_disk=$1
    lsblk ${fcos_disk} -J -oLABEL,PATH  |
	  jq -r '.blockdevices[] | select(.label == "EFI-SYSTEM")'.path
}


main $*

