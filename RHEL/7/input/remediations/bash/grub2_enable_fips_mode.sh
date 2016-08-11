# platform = Red Hat Enterprise Linux 7
sed -i 's/PRELINKING=yes/PRELINKING=no/g' /etc/sysconfig/prelink
prelink -u -a
dracut -f
if [ -e /sys/firmware/efi ]; then
	BOOT=`df /boot/efi | tail -1 | awk '{print $1 }'`
else
	BOOT=`df /boot | tail -1 | awk '{ print $1 }'`
fi
/sbin/grubby --update-kernel=ALL --args="boot=${BOOT} fips=1"