# platform = Red Hat Enterprise Linux 7

# include remediation functions library
. /usr/share/scap-security-guide/remediation_functions

# if prelink package is installed disable it, else ignore
if rpm -q prelink 2>&1 > /dev/null; then
	if grep -q '^PRELINKING=' /etc/sysconfig/prelink ; then
		sed -i 's/^PRELINKING=.*/# Set PRELINKING to "no" per security requirements\nPRELINKING=no/' /etc/sysconfig/prelink
	else
        	echo -e "\n# Set PRELINKING to 'no' per security requirements" >> /etc/sysconfig/prelink
        	echo "PRELINKING=no" >> /etc/sysconfig/prelink
	fi

	prelink -u -a
fi

package_install dracut-fips

dracut -f

# Correct the form of default kernel command line in  grub
if grep -q '^GRUB_CMDLINE_LINUX=.*fips=.*"'  /etc/default/grub; then
	# modify the GRUB command-line if a fips= arg already exists
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)fips=[^[:space:]]*\(.*"\)/\1 fips=1 \2/'  /etc/default/grub
else
	# no existing fips=arg is present, append it
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)"/\1 fips=1"/'  /etc/default/grub
fi

# Get the UUID of the device mounted at /boot.
BOOT_UUID=$(findmnt --noheadings --output uuid --target /boot)

if grep -q '^GRUB_CMDLINE_LINUX=".*boot=.*"'  /etc/default/grub; then
	# modify the GRUB command-line if a boot= arg already exists
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)boot=[^[:space:]]*\(.*"\)/\1 boot=UUID='"${BOOT_UUID} \2/" /etc/default/ grub
else
	# no existing boot=arg is present, append it
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)"/\1 boot=UUID='${BOOT_UUID}'"/'  /etc/default/grub
fi

# Correct the form of kernel command line for each installed kernel in the bootloader
/sbin/grubby --update-kernel=ALL --args="fips=1 boot=UUID=${BOOT_UUID}"
