# platform = multi_platform_debian
# reboot = false
# strategy = enable
# complexity = low
# disruption = low

unit=tmp.mount
mount_option=noexec

# check whether unit is in use
unit_check=$(systemctl -q list-units $unit | grep active)

if [ "x$unit_check" == "x" ]; then
    exit 0
fi

# check whether mount option is present
current_options=$(systemctl show $unit -P Options)
option_check=$(echo $current_options | grep $mount_option | wc -l)

# add systemd drop in to add missing option
if [ $option_check == "0" ]; then
    mkdir -p /etc/systemd/system/$unit.d
    cat > /etc/systemd/system/$unit.d/mount_options.conf <<EOF
[Mount]
Options=$current_options,$mount_option
EOF

    # unit changed on disk. reload.
    systemctl daemon-reload
    
    # note: mount point is probably in use, so we cannot restart
    # the unit without getting an error, but we may be able to
    # remount the filesystem with the new option
    mount_point=$(systemctl show $unit -P Where)
    mount $mount_point -o remount,$mount_option
fi

