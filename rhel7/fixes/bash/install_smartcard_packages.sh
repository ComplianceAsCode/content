# platform = Red Hat Enterprise Linux 7

# include remediation functions library
. /usr/share/scap-security-guide/remediation_functions

package_command install esc
package_command install pam_pkcs11
package_command install authconfig-gtk
