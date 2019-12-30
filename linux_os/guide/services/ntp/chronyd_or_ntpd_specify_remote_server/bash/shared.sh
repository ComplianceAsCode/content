# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol,multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions
populate var_multiple_time_servers

# Invoke the function without args, so its body is substituded right here.
ensure_there_are_servers_in_ntp_compatible_config_file

config_file="/etc/ntp.conf"
/usr/sbin/pidof ntpd || config_file="/etc/chrony.conf"

grep -q ^server "$config_file" || ensure_there_are_servers_in_ntp_compatible_config_file "$config_file" "$var_multiple_time_servers"
