function include_dconf_settings {
	:
}

# Function to configure DConf settings for RHEL and Fedora systems.
#
# Example Call(s):
#
#     dconf_settings 'org/gnome/login-screen' 'banner-message-enable' 'true' 'local.d' '10-banner'
#
function dconf_settings {
	local _path=$1 _key=$2 _value=$3 _db=$4 _settingFile=$5

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: dconf_settings 'dconf_path' 'dconf_setting' 'dconf_db' 'dconf_settingsfile'"
		echo "Aborting."
		exit 1
	fi

	# Check for setting in any of the DConf db directories
	# If files contain ibus or distro, ignore them.
	# The assignment assumes that individual filenames don't contain :
	readarray -t SETTINGSFILES < <(grep -r "\\[${_path}\\]" "/etc/dconf/db/" | grep -v "distro\\|ibus" | cut -d":" -f1)
	DCONFFILE="/etc/dconf/db/${_db}/${_settingFile}"
	DBDIR="/etc/dconf/db/${_db}"

	mkdir -p "${DBDIR}"

	if [ ${#SETTINGSFILES[@]} -eq 0 ]
	then
		[ ! -z ${DCONFFILE} ] || $(echo "" >> ${DCONFFILE})
		printf '%s\n' "[${_path}]" >> ${DCONFFILE}
		printf '%s=%s\n' "${_key}" "${_value}" >> ${DCONFFILE}
	else
		escaped_value="$(sed -e 's/\\/\\\\/g' <<< "$_value")"
		if grep -q "^\\s*${_key}" "${SETTINGSFILES[@]}"
		then
			sed -i "s/\\s*${_key}\\s*=\\s*.*/${_key}=${escaped_value}/g" "${SETTINGSFILES[@]}"
		else
			sed -i "\\|\\[${_path}\\]|a\\${_key}=${escaped_value}" "${SETTINGSFILES[@]}"
		fi
	fi

	dconf update
}

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
	LOCKFILES=$(grep -r "^/${_key}/${_setting}$" "/etc/dconf/db/" | grep -v "distro\\|ibus" | cut -d":" -f1)
	LOCKSFOLDER="/etc/dconf/db/${_db}/locks"

	mkdir -p "${LOCKSFOLDER}"

	if [[ -z "${LOCKFILES}" ]]
	then
		echo "/${_key}/${_setting}" >> "/etc/dconf/db/${_db}/locks/${_lockFile}"
	fi

	dconf update
}
