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
	SETTINGSFILES=($(grep -r "\[${_path}]" "/etc/dconf/db/" | grep -v "distro\|ibus" | cut -d":" -f1))
	DCONFFILE="/etc/dconf/db/${_db}/${_settingFile}"
	# Replace possible slash '/' character so we could use it in sed expressions below
	_path_esc=${_path//$'/'/$'\/'}

	if [[ -z "${SETTINGSFILES[@]}" ]]
	then
		[ ! -z ${DCONFFILE} ] || $(echo "" >> ${DCONFFILE})
		echo "[${_path}]" >> ${DCONFFILE}
		echo "${_key}=${_value}" >> ${DCONFFILE}
	else
		if grep -q "${_key}" ${SETTINGSFILES[@]}
		then
			sed -i "s/${_key}=.*/${_key}=${_value}/g" ${SETTINGSFILES[@]}
		else
			sed -i "/\[${_path_esc}]/ a\\${_key}=${_value}" ${SETTINGSFILES[@]}
		fi
	fi
}
