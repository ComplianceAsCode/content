# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions

package_command install aide

/usr/sbin/aide --init
/bin/cp -p /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
