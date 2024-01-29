# platform = multi_platform_ubuntu

if command -v nmcli >/dev/null 2>&1 ; then
    nmcli radio all off
elif [ -n "$(find /sys/class/net/*/ -type d -name wireless)" ]; then
    interfaces=$(find /sys/class/net/*/wireless -type d -name wireless | xargs -0 dirname | xargs basename)

    for i in $interfaces; do
        ip link set dev "$i" down
        drivers=$(basename "$(readlink -f /sys/class/net/"$i"/device/driver)")
        echo "install $drivers /bin/false" >> /etc/modprobe.d/disable_wireless.conf
        modprobe -r "$drivers"
     done
fi
