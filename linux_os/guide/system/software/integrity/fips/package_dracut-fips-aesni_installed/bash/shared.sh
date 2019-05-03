# platform = Red Hat Enterprise Linux 6,Red Hat Enterprise Linux 7,Oracle Linux 7

# include remediation functions library
. /usr/share/scap-security-guide/remediation_functions

if grep -q -m1 -o aes /proc/cpuinfo; then
	package_install dracut-fips-aesni
fi
