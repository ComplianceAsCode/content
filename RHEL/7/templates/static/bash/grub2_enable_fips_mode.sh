# platform = Red Hat Enterprise Linux 7

if grep --silent ^PRELINKING /etc/sysconfig/prelink ; then
        sed -i "s/^PRELINKING.*/PRELINKING=yes/g" /etc/sysconfig/prelink
else
        echo -e "\n# Set PRELINKING to 'yes' per security requirements" >> /etc/sysconfig/prelink
        echo "PRELINKING=yes" >> /etc/sysconfig/prelink
fi

prelink -u -a

dracut -f

if [ -e /sys/firmware/efi ]; then
	BOOT=`df /boot/efi | tail -1 | awk '{print $1 }'`
else
	BOOT=`df /boot | tail -1 | awk '{ print $1 }'`
fi

/sbin/grubby --update-kernel=ALL --args="boot=${BOOT} fips=1"
