#!/bin/bash

if [ $(whoami) != "root" ]; then
    echo "This script must be run as root!"
    exit 1
fi

if [ -z $(which gedit) ]; then
    echo
    echo "ERROR: gedit needs to be installed first!"
    echo
    echo "Can be installed with [Ubuntu/Debian] : sudo apt-get install gedit"
    exit 1 
fi

#
# Mount the partition if not already
# $1: Partition name
# $2: Mount point
function mountpart {
    local part_name="$1"
    local mount_point="$2"
    if [ -e "${mount_point}" ]; then
        umount "${mount_point}" 2> /dev/null
        umount "${part_name}" 2> /dev/null
        rm -rf "${mount_point}"
    fi
    mkdir "${mount_point}"
    mount "${part_name}" "${mount_point}"
}

#
# Get partition number from partition name
function getPartNo {
    echo "$1" | sed -E 's|^.*((mmcblk\|nvme[0-9]+n)[0-9]+p\|sd[a-z]+)([0-9]+)$|\3|'
}

#
# The main function
# $1: cloudready.img
# $2: ROOT-A partition
# $3: STATE partition
# $4: OEM partition
function main {
    if ! [ $# -ge 4 ]; then
        echo "Invalid argument"
        echo "Usage: cloudready-dualboot.sh <cloudready.img> <root_a_part> <state_part> <oem_part>"
        exit 1
    fi
    
    local skip_state=0
    if [ "$5" == "[--skip-state]" ]; then
        skip_state=1
    fi
    
    local cloudready_image=$1
    local hdd_root_a_part="/dev/$2"
    local hdd_state_part="/dev/$3"
    local hdd_oem_part="/dev/$4"
    
    # Mount the image
    local img_disk=`/sbin/losetup --show -fP "${cloudready_image}"`
    local img_root_a_part="${img_disk}p18"
    local img_state_part="${img_disk}p16"
    local img_oem_part="${img_disk}p23"
    
    local user=`logname`
    if [ $? -ne 0 ]; then
        user="chronos"
    fi
    local root="/home/${user}"
    local root_a="${root}/roota"
    local local_root_a="${root}/localroota"
    local state="${root}/state"
    local local_state="${root}/localstate"
    local oem="${root}/oem"
    local local_oem="${root}/localoem"
    uuid="blkid -s UUID -o value /dev/$2"
    
    echo
    echo "------------------------------------"
    echo "   Cloudready Dualboot Installer"
    echo "------------------------------------"
    echo
    echo -n "Enter the disk number (Only Number): "
    read diskno
    echo
    echo "Installing Cloudready...."
    echo "(Please wait this might take a while)"
    echo
    echo -n "Step 1: Copying ROOT-A..."
    # Mount partition#3 (ROOT-A) of the image
    mountpart "${img_root_a_part}" "${root_a}"
    # Mount the ROOT-A partition
    mountpart "${hdd_root_a_part}" "${local_root_a}"
    # Delete all the contents of the partition
    rm -Rf "${local_root_a}"/*
    # Copy files
    cp -a "${root_a}"/* "${local_root_a}" 2> /dev/null
    if [ $? -eq 0 ]; then
        echo "Done Succesfully"
    else
        echo
        echo "Failed Copying Files, Please check your image"
        exit 1
    fi

    
    echo -n "Step 2: Copying OEM..."
    # Mount partition# (OEM) of the image
    mountpart "${img_oem_part}" "${oem}"
    # Mount the OEM partition of the HDD
    mountpart "${hdd_oem_part}" "${local_oem}"
    # Delete all the contents of the local partition
    rm -Rf "${local_oem}"/*
    # Copy files
    cp -a "${oem}"/* "${local_oem}" 2> /dev/null
      if [ $? -eq 0 ]; then
          echo "Done Succesfully"
      else
          echo
          echo "Failed Copying Files, Please check your image"
          exit 1
      
    fi
    if [ ${skip_state} -ne 1 ]; then
        echo -n "Step 3: Copying STATE..."
        # Mount partition#1 (STATE) of the image
        mountpart "${img_state_part}" "${state}"
        # Mount the STATE partition of the HDD
        mountpart "${hdd_state_part}" "${local_state}"
        # Delete all the contents of the local partition
        rm -Rf "${local_state}"/*
        # Copy files
        cp -a "${state}"/* "${local_state}" 2> /dev/null
        if [ $? -eq 0 ]; then
            echo "Done Sucessfully"
        else
            echo
            echo "Failed copying files, please check your image"
            exit 1
        fi
    else
        echo "Skipping state"
    fi
    echo "Step 4: Fixing partition data..."
    sed -i "s/#ROOT/${hdd_root_a_part_no}/g" partition-layout.sh
    sed -i "s/#STATE/${hdd_state_part_no}/g" partition-layout.sh
    sed -i "s/#OEM/${hdd_oem_part_no}/g" partition-layout.sh
    gedit partition-layout.sh
    gedit ${local_root_a}/usr/share/misc/partition-layout.sh
    if [ $? -eq 0 ]; then
        echo "Done Succesfully"
    else
        echo
        echo "Fixing Partition data Failed, try fixing it manually"
    fi
    echo "Step 4: Unmounting the partitions"
    umount ${local_root_a}
    umount ${local_state}
    umount ${local_oem}
    echo "Step 5: Generating GRUB Configuration.."
    echo 
    echo "***************************************************************************"
    echo -n "menuentry Cloudready {
insmod part_gpt
insmod ext2
set root=(hd$diskno,gpt"${hdd_root_a_part_no}")
search --no-floppy --fs-uuid --set=root ";eval $uuid 
    echo "linux /boot/vmlinuz root="${hdd_root_a_part}" init=/sbin/init rootwait rw noresume console=tty2 i915.modeset=1 loglevel=1 quiet noinitrd tpm_tis.force=1 cros_secure cros_debug
}"
    echo "****************************************************************************"
    echo "Copy the above grub entry and paste it at /etc/grub.d/40_custom"
    echo 
    echo "Installation complete!"
    exit 0
}

# Exec part
main "$@"
