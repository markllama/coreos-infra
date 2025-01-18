#!/bin/bash

#
# Create a USB bootable stick with a customized CoreOS live image on it
#
# Base image spec
# stream       - default (stable)
# architecture - default (x86_64)
# platform     - default (metal)
# format       - iso
# directory    - default (.)

: SDCARD_DEVICE=${SDCARD_DEVICE:=/dev/sda}

# Download or check the CoreOS image
BASE_IMAGE_PATH=$( coreos-installer download --format iso )

# Embed the installation parameters and configuration into the image
coreos-installer iso customize \
     --dest-ignition coreos-infra.ign \
     --dest-device /dev/sda \
     ${BASE_IMAGE_PATH}

sudo dd status=progress if=${BASE_IMAGE_PATH} of=${SDCARD_DEVICE}
		 
