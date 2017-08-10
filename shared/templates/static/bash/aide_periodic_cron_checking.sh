# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions

package_command install aide

if ! grep -q "/usr/sbin/aide --check" /etc/crontab ; then
    echo "05 4 * * * root /usr/sbin/aide --check" >> /etc/crontab
fi
