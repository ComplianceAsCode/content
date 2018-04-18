# Function to configure DConf locks for RHEL and Fedora systems.
#
# Example Call(s):
#
#     dconf_lock 'org/gnome/login-screen' 'banner-message-enable' 'local.d' 'banner'
#
function dconf_lock {
	local _key=$1 _setting=$2 _db=$3 _lockFile=$4

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: dconf_lock 'dconf_path' 'dconf_setting' 'dconf_db' 'dconf_lockfile'"
	  	echo "Aborting."
		exit 1
	fi

	# Check for setting in any of the DConf db directories
	LOCKFILES=($(grep -r "^/${_key}/${_setting}$" "/etc/dconf/db/" | grep -v "distro\|ibus" | cut -d":" -f1))

	if [[ -z "${LOCKFILES}" ]]
	then
		echo "/${_key}/${_setting}" >> "/etc/dconf/db/${_db}/locks/${_lockFile}"
	fi
}

