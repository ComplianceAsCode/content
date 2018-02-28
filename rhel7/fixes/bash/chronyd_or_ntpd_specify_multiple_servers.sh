# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_multiple_time_servers


config_file="/etc/ntp.conf"
/usr/sbin/pidof ntpd || config_file="/etc/chrony.conf"

[ "$(grep -c '^server' "$config_file")" -gt 1 ] || rhel7_handle_ntp_like_file "$config_file" "$var_multiple_time_servers"
