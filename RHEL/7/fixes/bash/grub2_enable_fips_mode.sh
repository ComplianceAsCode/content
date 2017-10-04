# platform = Red Hat Enterprise Linux 7

# include remediation functions library
. /usr/share/scap-security-guide/remediation_functions

if grep --silent ^PRELINKING /etc/sysconfig/prelink ; then
        sed -i "s/^PRELINKING.*/PRELINKING=no/g" /etc/sysconfig/prelink
else
        echo -e "\n# Set PRELINKING to 'no' per security requirements" >> /etc/sysconfig/prelink
        echo "PRELINKING=no" >> /etc/sysconfig/prelink
fi

prelink -u -a

package_command install dracut-fips

dracut -f

if [ -e /sys/firmware/efi ]; then
	BOOT=`df /boot/efi | tail -1 | awk '{print $1 }'`
else
	BOOT=`df /boot | tail -1 | awk '{ print $1 }'`
fi

# Correct the form of default kernel command line in /etc/default/grub
if ! grep -q "^GRUB_CMDLINE_LINUX=\".*fips=1.*\"" /etc/default/grub;
then
  # Append 'fips=1' argument to /etc/default/grub (if not present yet)
  sed -i "s/\(GRUB_CMDLINE_LINUX=\)\"\(.*\)\"/\1\"\2 fips=1\"/" /etc/default/grub
fi

# Edit runtime setting
# Correct the form of kernel command line for each installed kernel in the bootloader
/sbin/grubby --update-kernel=ALL --args="boot=${BOOT} fips=1"
