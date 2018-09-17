# platform = Red Hat Enterprise Linux 7

# include remediation functions library
. /usr/share/scap-security-guide/remediation_functions

if [ $(cat /etc/system-release-cpe | cut -d":" -f3) == "redhat" ] ; then
	package_install dracut-fips
fi
