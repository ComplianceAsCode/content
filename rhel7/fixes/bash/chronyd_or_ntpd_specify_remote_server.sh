# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_multiple_time_servers

# Invoke the function without args, so its body is substituded right here.
rhel7_handle_ntp_like_file

config_file="/etc/ntp.conf"
/usr/sbin/pidof ntpd || config_file="/etc/chrony.conf"

grep -q ^server "$config_file" || rhel7_handle_ntp_like_file "$config_file" "$var_multiple_time_servers"
