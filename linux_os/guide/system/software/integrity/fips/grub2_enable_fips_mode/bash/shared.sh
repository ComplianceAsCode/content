# platform = Oracle Linux 7,Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_rhv,multi_platform_wrlinux

# include remediation functions library
. /usr/share/scap-security-guide/remediation_functions

{{{ bash_disable_prelink() }}}

if grep -q -m1 -o aes /proc/cpuinfo; then
	{{{ bash_package_install("dracut-fips-aesni") }}}
fi
{{{ bash_package_install("dracut-fips") }}}

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
