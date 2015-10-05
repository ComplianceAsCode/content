# platform = Red Hat Enterprise Linux 6

# NOTE: Run-time reconfiguration of partitions' mount options is not possible.
# After performing this remediation be sure to also subsequently reboot the
# system as soon as possible for the remediation to take the effect!

# Shortened ID for frequently used character class
SP="[:space:]"

# Load /etc/fstab's content with LABEL= and UUID= tags expanded to real
# device names into FSTAB_REAL_DEVICES array splitting items by newline
IFS=$'\n' FSTAB_REAL_DEVICES=($(findmnt --fstab --evaluate --noheadings))

for line in ${FSTAB_REAL_DEVICES[@]}
do
    # For each line:
    # * squeeze multiple space characters into one,
    # * split line content info four columns (target, source, fstype, and
    #   mount options) by space delimiter
    IFS=$' ' read TARGET SOURCE FSTYPE MOUNT_OPTIONS <<< "$(echo $line | tr -s ' ')"

    # Filter the targets according to the following criteria:
    # * don't include record for root partition,
    # * include the target only if it has the form of '/word.*' (not to include
    #   special entries like e.g swap),
    # * include the target only if its source has the form of '/dev.*'
    #   (to process only local partitions)
    if [[ ! $TARGET =~ ^\/$ ]] 		&&	# Don't include root partition
       [[ $TARGET =~ ^\/[A-Za-z0-9_] ]] &&	# Include if target =~ '/word.*'
       [[ $SOURCE =~ ^\/dev ]]			# Include if source =~ '/dev.*'
    then

        # Check the mount options column if it doesn't contain 'nodev' keyword yet
        if ! grep -q "nodev" <<< "$MOUNT_OPTIONS"
        then
            # Check if current mount options is empty string ('') meaning
            # particular /etc/fstab row contain just 'defaults' keyword
            if [[ ${#MOUNT_OPTIONS} == "0" ]]
            then
                # If so, add 'defaults' back and append 'nodev' keyword
                MOUNT_OPTIONS="defaults,nodev"
            else
                # Otherwise append just 'nodev' keyword
                MOUNT_OPTIONS="$MOUNT_OPTIONS,nodev"
            fi

            # Escape possible slash ('/') characters in target for use as sed
            # expression below
            TARGET_ESCAPED=${TARGET//$'/'/$'\/'}
            # This target doesn't contain 'nodev' in mount options yet (and meets
            # the above filtering criteria). Therefore obtain particular /etc/fstab's
            # row into FSTAB_TARGET_ROW variable separating the mount options field with
            # hash '#' character
            FSTAB_TARGET_ROW=$(sed -n "s/\(.*$TARGET_ESCAPED[$SP]\+$FSTYPE[$SP]\+\)\([^$SP]\+\)/\1#\2#/p" /etc/fstab)
            # Split the retrieved value by the hash '#' delimiter to get the
            # row's head & tail (i.e. columns other than mount options) which won't
            # get modified
            IFS=$'#' read TARGET_HEAD TARGET_OPTS TARGET_TAIL <<< "$FSTAB_TARGET_ROW"
            # Replace old mount options for particular /etc/fstab's row (for this target
            # and fstype) with new mount options
            sed -i "s#${TARGET_HEAD}\(.*\)${TARGET_TAIL}#${TARGET_HEAD}${MOUNT_OPTIONS}${TARGET_TAIL}#" /etc/fstab

        fi
    fi
done
