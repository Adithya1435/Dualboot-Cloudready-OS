#!/bin/bash

if [ $UID -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

#
# Mount the partition if not already
# $1: Partition name
# $2: Mount point
function mountIfNotAlready {
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
# $2: EFI-SYSTEM parition
# $3: ROOT-A partition
# $4: STATE partition
# $5: OEM partition
function main {
    if ! [ $# -ge 4 ]; then
        echo "Invalid argument"
        echo "Usage: cloudready-dualboot.sh <cloudready.img> <efi_part> <root_a_part> <state_part> <oem_part>"
        exit 1
    fi
    
    local skip_state=0
    
    local cloudready_image=$1
    local hdd_efi_part="/dev/$2"
    local hdd_root_a_part="/dev/$3"
    local hdd_state_part="/dev/$4"
    local hdd_oem_part="/dev/$5"
    
    # Mount the image
    local img_disk=`/sbin/losetup --show -fP "${cloudready_image}"`
    local img_efi_part="${img_disk}p27"
    local img_root_a_part="${img_disk}p18"
    local img_state_part="${img_disk}p16"
    
    local user=`logname`
    if [ $? -ne 0 ]; then
        user="chronos"
    fi
    local root="/home/${user}"
    local efi_dir="${root}/efi"
    local local_efi_dir="${root}/localefi"
    local root_a="${root}/roota"
    local local_root_a="${root}/localroota"
    local state="${root}/state"
    local local_state="${root}/localstate"
    
    echo
    echo "-----------------------------"
    echo "Cloudready Dualboot Installer"
    echo "-----------------------------"
    echo
    echo "Enter the disk number (Only Number): "
    read diskno
    echo
    echo "Enter the UUID of the ROOT-A partition: "
    read uuid
    echo
    echo "Installing Cloudready...."
    echo
    echo -n "Step 1: Copying EFI-SYSTEM.."
    # Mount partition#27 (EFI-SYSTEM) of the image
    mountIfNotAlready "${img_efi_part}" "${efi_dir}"
    # Mount the EFI-SYSTEM partition of the HDD
    mountIfNotAlready "${hdd_efi_part}" "${local_efi_dir}"
    # Delete all the contents of the local partition
    rm -Rf "${local_efi_dir}"/*
    # Copy files
    cp -a "${efi_dir}"/* "${local_efi_dir}" 2> /dev/null
    if [ $? -eq 0 ]; then
        echo "Done Succesfully"
    else
        echo
        echo "Failed Copying Files, Please check your image"
        exit 1
    fi

    echo -n "Step 2: Copying ROOT-A..."
    # Mount partition#18 (ROOT-A) of the image
    mountIfNotAlready "${img_root_a_part}" "${root_a}"
    # Mount the ROOT-A partition
    mountIfNotAlready "${hdd_root_a_part}" "${local_root_a}"
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

    
    echo -n "Step 3: Copying STATE..."
    # Mount partition#16 (STATE) of the image
    mountIfNotAlready "${img_state_part}" "${state}"
    # Mount the STATE partition of the HDD
    mountIfNotAlready "${hdd_state_part}" "${local_state}"
    # Delete all the contents of the local partition
    rm -Rf "${local_state}"/*
    # Copy files
    cp -a "${state}"/* "${local_state}" 2> /dev/null
      if [ $? -eq 0 ]; then
          echo "Done Succesfully"
      else
          echo
          echo "Failed Copying Files, Please check your image"
          exit 1
      
    fi

    # Post installation
    echo -n "Step 4: Modifying GRUB..."
    local hdd_uuid=`/sbin/blkid -s PARTUUID -o value "${hdd_root_a_part}"`
    local old_uuid=`cat "${local_efi_dir}/efi/boot/grub.cfg" | grep -m 1 "PARTUUID=" | awk '{print $15}' | cut -d'=' -f3`
    sed -i "s/${old_uuid}/${hdd_uuid}/" "${local_efi_dir}/efi/boot/grub.cfg"
    if [ $? -eq 0 ]; then
        echo "Done Succesfully"
    else
        echo
        echo "Failed, please try fixing it manually."
        # exit 1 # This isn't a critical error
    fi
    
    echo -n "Step 5: Updating partition data..."
    local hdd_efi_part_no=`getPartNo "${hdd_efi_part}"`
    local hdd_root_a_part_no=`getPartNo "${hdd_root_a_part}"`
    local hdd_state_part_no=`getPartNo "${hdd_state_part}"`
    local hdd_oem_part_no=`getPartNo "${hdd_oem_part}"`
    local write_gpt_path="${local_root_a}/usr/sbin/write_gpt.sh"
    # Remove unnecessary partitions & update properties
    cat "${write_gpt_path}" | grep -vE "_(KERN_(A|B|C)|2|4|6|ROOT_(B|C)|5|7|OEM|8|RESERVED|9|10|RWFW|11)" | sed \
    -e "s/^\(\s*PARTITION_NUM_EFI_SYSTEM=\)\"[0-9]\+\"$/\1\"${hdd_efi_part_no}\"/g" \
    -e "s/^\(\s*PARTITION_NUM_12=\)\"[0-9]\+\"$/\1\"${hdd_efi_part_no}\"/g" \
    -e "s/^\(\s*PARTITION_NUM_ROOT_A=\)\"[0-9]\+\"$/\1\"${hdd_root_a_part_no}\"/g" \
    -e "s/^\(\s*PARTITION_NUM_3=\)\"[0-9]\+\"$/\1\"${hdd_root_a_part_no}\"/g" \
    -e "s/^\(\s*PARTITION_NUM_STATE=\)\"[0-9]\+\"$/\1\"${hdd_state_part_no}\"/g" \
    -e "s/^\(\s*PARTITION_NUM_1=\)\"[0-9]\+\"$/\1\"${hdd_state_part_no}\"/g" \
    -e "s/\(\s*DEFAULT_ROOTDEV=\).*$/\1\"\"/" | tee "${write_gpt_path}" > /dev/null
    # -e "w ${write_gpt_path}" # Doesn't work on CrOS
    if [ $? -eq 0 ]; then
        echo "Done Succesfully"
    else
        echo
        echo "Failed updating partition data, please try fixing it manually."
        # exit 1 # This isn't a critical error
    fi
    echo -n "Step 6: Post installation..."
    local tp_line=`grep -Fn "06cb:*" "${local_root_a}/etc/gesture/40-touchpad-cmt.conf" | sed 's/^\([0-9]\+\):.*$/\1/'`
    tp_line=$((tp_line+3)) # Add at line#21
    sed -i "${tp_line}a\    # Enable tap to click\n    Option          \"libinput Tapping Enabled\" \"1\"\n    Option          \"Tap Minimum Pressure\" \"0.1\"\n" "${local_root_a}/etc/gesture/40-touchpad-cmt.conf"
    if [ $? -eq 0 ]; then
        echo "Done Succesfully"
    else
        echo
        echo ""
        # exit 1 # This isn't a critical error
    fi
    echo "Step 7: Fixing partition data..."
    sed -i "s/#EFI/${hdd_efi_part_no}/g" partition-layout.sh
    sed -i "s/#ROOTA/${hdd_root_a_part_no}/g" partition-layout.sh
    sed -i "s/#STATE/${hdd_state_part_no}/g" partition-layout.sh
    sed -i "s/#OEM/${hdd_oem_part_no}/g" partition-layout.sh
    cp partition-layout.sh ${local_root_a}/usr/share/misc
    if [ $? -eq 0 ]; then
        echo "Done Succesfully"
    else
        echo
        echo "Fixing Partition data Failed, try fixing it manually"
    fi
    echo "Step 8: Generating GRUB Configuration.."
    echo 
    echo "************************************************************************"
    echo "menuentry Cloudready {
insmod part_gpt
insmod ext2
set root=(hd$diskno,gpt"${hdd_root_a_part_no}")
search --no-floppy --fs-uuid --set=root $uuid
linux /boot/vmlinuz root=/dev/"${hdd_root_a_part}" init=/sbin/init rootwait rw noresume console=tty2 i915.modeset=1 loglevel=1 quiet noinitrd tpm_tis.force=1 cros_secure cros_debug
}"
    echo "*************************************************************************"
    echo "Copy the above grub entry and paste it at /etc/grub.d/40_custom"
    echo 
    echo "Installation complete!"
    exit 0
}

# Exec part
main "$@"
