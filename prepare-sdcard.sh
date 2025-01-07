#!/bin/bash

OPTSTRING="b:di:ns:u:Uv"

UEFI_TMP=$(mktemp -d)

DEFAULT_STREAM=stable
DEFAULT_BLOCK_DEVICE=/dev/sda
DEFAULT_IGNITION_FILE=config.ign
DEFAULT_UEFI_VERSION=1.36
#DEFAULT_UEFI_ONLY=

FW_URL_ROOT=https://github.com/pftf/RPi4/releases/download


function main() {
    echo start
    parse_arguments $*

    [ "${UEFI_ONLY}" = "true" ] ||
	install_coreos ${STREAM} ${BLOCK_DEVICE} ${IGNITION_FILE}

    sleep 5
    local part="$(uefi_partition ${BLOCK_DEVICE})"
    echo $part
    
    sudo mount ${part} ${UEFI_TMP}
    get_uefi_files ${UEFI_VERSION} ${UEFI_TMP}
    sudo umount ${part}
    sudo rmdir ${UEFI_TMP}

}

function parse_arguments() {

    echo parse_arguments
    while getopts "${OPTSTRING}" opt; do
     	case $opt in
     	    b) BLOCK_DEVICE=${OPTARG}
     	       ;;

     	    d) DEBUG=true
     	       ;;

	    i) IGNITION_FILE=${OPTARG}
	       ;;

     	    n) NOOP=echo
     	       ;;

     	    s) STREAM=${OPTARG}
     	       ;;

	    u) UEFI_VERSION=${OPTARG}
	       ;;

	    U) UEFI_ONLY=true
	       ;;
	    
	    v) VERBOSE=true
	       ;;
     	esac
    done

    : BLOCK_DEVICE="${BLOCK_DEVICE:=$DEFAULT_BLOCK_DEVICE}"
    : STREAM="${STREAM:=$DEFAULT_STREAM}"
    : IGNITION_FILE=${IGNITION_FILE:=$DEFAULT_IGNITION_FILE}
    : UEFI_VERSION=${UEFI_VERSION:=$DEFAULT_UEFI_VERSION}
}

function install_coreos() {
     local stream=$1
     local disk=$2
     local ignition=$3
     ${NOOP} sudo coreos-installer install -a aarch64 -s $stream -i $ignition $disk
}

function uefi_partition() {
    local block_device=$1
    lsblk $block_device -J -oLABEL,PATH | jq -r '.blockdevices[] | select(.label == "EFI-SYSTEM")'.path
}

function get_uefi_files() {
    local vers=$1
    local dest=$2

    local fw_zip=RPi4_UEFI_Firmware_v${vers}.zip
    
    #${NOOP} mkdir ${dest}
    ${NOOP} sudo curl -L -o ${dest}/${fw_zip} $FW_URL_ROOT/v${vers}/${fw_zip}
    ${NOOP} sudo unzip ${dest}/${fw_zip} -d ${dest}
    ${NOOP} sudo rm -f ${dest}/${fw_zip}
}

#
#
#

main $*
