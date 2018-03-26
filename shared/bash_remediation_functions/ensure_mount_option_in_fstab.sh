# $1: mount point
# $2: new mount point option
function ensure_mount_option_in_fstab {
	local _mount_point="$1" _new_opt="$2" _mount_point_match_regexp="" _previous_mount_opts=""
	_mount_point_match_regexp="[[:space:]]$_mount_point[[:space:]]"

	if [ $(grep "$_mount_point_match_regexp" /etc/fstab | grep -c "$_new_opt" ) -eq 0 ]; then
		_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/fstab | awk '{print $4}')
		sed -i "s/\(${_mount_point_match_regexp}.*${_previous_mount_opts}\)/\1,${_new_opt}/" /etc/fstab
	fi
}


function remove_defaults_from_fstab_if_overriden {
	_mount_point_match_regexp="[[:space:]]$1[[:space:]]"
	if [ $(grep "$_mount_point_match_regexp" /etc/fstab | grep -q "defaults,") -gt 0 ]
	then
		sed -i "s/\(${_mount_point_match_regexp}.*\)defaults,/\1/" /etc/fstab
	fi
}
