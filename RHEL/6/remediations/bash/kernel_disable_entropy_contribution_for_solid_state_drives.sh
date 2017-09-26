# platform = Red Hat Enterprise Linux 6

# First obtain the list of block devices present on system into array
#
# Used lsblk options:
# -o NAME	Display only block device name
# -a		Display all devices (including empty ones) in the list
# -d		Don't print device holders or slaves information
# -n		Suppress printing of introductory heading line in the list
SYSTEM_BLOCK_DEVICES=($(/bin/lsblk -o NAME -a -d -n))

# For each SSD block device from that list
# (device where /sys/block/DEVICE/queue/rotation == 0)
for BLOCK_DEVICE in "${SYSTEM_BLOCK_DEVICES[@]}"
do
	# Verify the block device is SSD
	if grep -q "0" /sys/block/${BLOCK_DEVICE}/queue/rotational
	then
		# If particular SSD is configured to contribute to
		# random-number entropy pool, disable it
		if grep -q "1" /sys/block/${BLOCK_DEVICE}/queue/add_random
		then
			echo "0" > /sys/block/${BLOCK_DEVICE}/queue/add_random
		fi
	fi
done
