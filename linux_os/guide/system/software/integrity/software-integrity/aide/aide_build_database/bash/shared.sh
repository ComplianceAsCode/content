# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions

package_install aide

/usr/sbin/aide --init
/bin/cp -p /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
