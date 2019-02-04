# platform = Red Hat Enterprise Linux 6,Red Hat Enterprise Linux 7,Oracle Linux 7

# include remediation functions library
. /usr/share/scap-security-guide/remediation_functions

package_install dracut-fips
