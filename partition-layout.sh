get_root_partition_number() {
    local rootdev
    # Get the root device, e.g. /dev/sda18. The -s option makes it
    # work with verity enabled.
    rootdev=$(rootdev -s /)
    # Regex copied from get_partition_number in chromeos-common.sh
    echo "${rootdev}" | sed 's/^.*[^0-9]\([0-9]\+\)$/\1/'
}

calculate_partition_offset() {
    local root
    root=$(get_root_partition_number)

    # Check if running from 18 or 20, which are the ROOT-A and ROOT-B
    # partition numbers in the post-dualboot layout.
    if [ "${root}" = 18 ] || [ "${root}" = 20 ]; then
        echo 15
    else
        echo 0
    fi
}

is_old_partition_layout() {
    local offset
    offset=$(calculate_partition_offset)

    # the old partition layout has no offset
    if [ "${offset}" = 0 ]; then
        echo 1
    else
        echo 0
    fi
}

#NEVERWARE_PARTITION_OFFSET=$(calculate_partition_offset)

#PARTITION_NUM_STATE=$((1 + NEVERWARE_PARTITION_OFFSET))
#PARTITION_NUM_KERN_A=$((2 + NEVERWARE_PARTITION_OFFSET))
#PARTITION_NUM_ROOT_A=$((3 + NEVERWARE_PARTITION_OFFSET))
#PARTITION_NUM_KERN_B=$((4 + NEVERWARE_PARTITION_OFFSET))
#PARTITION_NUM_ROOT_B=$((5 + NEVERWARE_PARTITION_OFFSET))
#PARTITION_NUM_KERN_C=$((6 + NEVERWARE_PARTITION_OFFSET))
#PARTITION_NUM_ROOT_C=$((7 + NEVERWARE_PARTITION_OFFSET))
#PARTITION_NUM_OEM=$((8 + NEVERWARE_PARTITION_OFFSET))
#PARTITION_NUM_RWFW=$((11 + NEVERWARE_PARTITION_OFFSET))
#PARTITION_NUM_EFI_SYSTEM=$((12 + NEVERWARE_PARTITION_OFFSET))

PARTITION_NUM_STATE=#STATE
PARTITION_NUM_KERN_A=#STATE
PARTITION_NUM_ROOT_A=#ROOTA
PARTITION_NUM_KERN_B=#ROOTA
PARTITION_NUM_ROOT_B=#ROOTA
PARTITION_NUM_KERN_C=#ROOTA
PARTITION_NUM_ROOT_C=#ROOTA
PARTITION_NUM_OEM=#OEM
PARTITION_NUM_RWFW=#OEM
PARTITION_NUM_EFI_SYSTEM=#EFI
