# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_multiple_time_servers


config_file="/etc/ntp.conf"
/usr/sbin/pidof ntpd || config_file="/etc/chrony.conf"


# This function is duplicate of function defined in chronyd_or_ntpd_specify_multiple_servers.sh
handle_ntp_like_file()
{
  local _config_file="$1"
  if ! grep -q '#[[:space:]]*server' "$_config_file"; then
    for server in $(echo "$var_multiple_time_servers" | tr ',' '\n') ; do
      printf '\nserver %s iburst' "$server" >> "$_config_file"
    done
  else
    sed -i 's/#[ \t]*server/server/g' "$_config_file"
  fi
}


grep -q ^server "$config_file" || handle_ntp_like_file "$config_file"
