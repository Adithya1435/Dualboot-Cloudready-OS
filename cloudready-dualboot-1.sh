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

function getPartNo {
    echo "$1" | sed -E 's|^.*((mmcblk\|nvme[0-9]+n)[0-9]+p\|sd[a-z]+)([0-9]+)$|\3|'
}

function main {
    if ! [ $# -ge 3 ]; then
        echo "Invalid argument!"
        echo "Usage: bash cloudready-dualboot-1.sh <root_a_part> <state_part> <oem_part>"
        exit 1
    fi
    local user=`logname`
    local hdd_root_a_part="/dev/$1"
    local hdd_state_part="/dev/$2"
    local hdd_oem_part="/dev/$3"
    if [ ! -d "/media/"${user}"/ROOT-A" ]; then
         echo "ERROR: Please mount the image before running this script!"
         exit 1
    fi
    if [ ! -d "/home/"${user}"/localroot" ]; then
         mkdir /home/"${user}"/localroot
    fi
    if [ ! -d "/home/"${user}"/localstate" ]; then
         mkdir /home/"${user}"/localstate
    fi
    if [ ! -d "/home/"${user}"/localoem" ]; then
         mkdir /home/"${user}"/localoem
    fi
    uuid="blkid -s UUID -o value /dev/$1"
    mount "${hdd_root_a_part}" /home/"${user}"/localroot
    mount "${hdd_state_part}" /home/"${user}"/localstate
    mount "${hdd_oem_part}" /home/"${user}"/localoem
    echo
    echo "-----------------------------"
    echo "Cloudready Dualboot Installer"
    echo "-----------------------------"
    echo
    echo -n "Enter the disk number (Only Number): "
    read diskno
    echo
    sleep 1
    echo "Installing Cloudready...."
    sleep 1
    echo "(Please wait this might take a while)"
    echo
    sleep 1
    echo -n "Step 1: Writing partition 1 (ROOT-A)..."
    #Delete all the contents
    rm -Rf /home/"${user}"/localroot/*
    #Copy the files from image to the localroot
    cp -a /media/"${user}"/ROOT-A/* /home/"${user}"/localroot
    if [ $? -eq 0 ]; then
        echo "Done Succesfully"
    else
        echo
        echo "Failed Copying Files, Please check your image"
        exit 1
    fi
    echo -n "Step 2: Writing partition 2 (STATE)..."
    #Delete all the contents
    rm -Rf /home/"${user}"/localstate/*
    #Copy the files from image to the localstate
    cp -a /media/"${user}"/STATE/* /home/"${user}"/localstate
    if [ $? -eq 0 ]; then
        echo "Done Succesfully"
    else
        echo
        echo "Failed Copying Files, Please check your image"
        exit 1
    fi
    echo -n "Step 3: Writing partition 3 (OEM)..."
    #Delete all the contents
    rm -Rf /home/"${user}"/localoem/*
    #Copy the files from image to the localstate
    cp -a /media/"${user}"/OEM/* /home/"${user}"/localoem
    if [ $? -eq 0 ]; then
        echo "Done Succesfully"
    else
        echo
        echo "Failed Copying Files, Please check your image"
        exit 1
    fi
    echo -n "Step 4: Fixing partition data..."
    local hdd_root_a_part_no=`getPartNo "${hdd_root_a_part}"`
    local hdd_state_part_no=`getPartNo "${hdd_state_part}"`
    local hdd_oem_part_no=`getPartNo "${hdd_oem_part}"`
    sed -i "s/#ROOT/${hdd_root_a_part_no}/g" partition-layout.sh
    sed -i "s/#STATE/${hdd_state_part_no}/g" partition-layout.sh
    sed -i "s/#OEM/${hdd_oem_part_no}/g" partition-layout.sh
    gedit partition-layout.sh
    gedit /home/"${user}"/localroot/usr/share/misc/partition-layout.sh
    if [ $? -eq 0 ]; then
        echo "Done Succesfully"
    else
        echo
        echo "Fixing Partition data Failed, try fixing it manually"
    fi
    echo "Step 5: Unmounting the partitions..."
    umount /home/"${user}"/localroot
    umount /home/"${user}"/localstate
    umount /home/"${user}"/localoem
    echo "Step 6: Generating GRUB Configuration.."
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
