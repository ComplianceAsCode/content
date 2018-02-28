# Function ensures that the ntp/chrony config file contains valid server entries
# $1: Path to the config file
# $2: Comma-separated list of servers
function rhel7_handle_ntp_like_file {
	local _config_file="$1" _servers_list="$2"
	if ! grep -q '#[[:space:]]*server' "$_config_file"; then
		for server in $(echo "$_servers_list" | tr ',' '\n') ; do
			printf '\nserver %s iburst' "$server" >> "$_config_file"
		done
	else
		sed -i 's/#[ \t]*server/server/g' "$_config_file"
	fi
}
