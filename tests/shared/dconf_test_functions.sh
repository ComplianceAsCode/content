
# Check if gdm and dconf are installed, if not then install them
install_dconf_and_gdm_if_needed(){
	if ! rpm -q dconf; then
		yum -y install dconf
	fi

	if ! rpm -q gdm; then
		yum -y install gdm
	fi
}

# Wipes out dconf db settings directory
clean_dconf_settings(){
	rm -rf /etc/dconf/db/*
}

# Wipes out dconf db files
remove_dconf_databases(){
	rm -f /etc/dconf/db/*
}

# Adds a new dconf setting
# $1 _path
# $2 _setting
# $3 _value
# $4 _db
# $5 _settingFile
add_dconf_setting() {
	local _path=$1 _setting=$2 _value=$3 _db=$4 _settingFile=$5
	mkdir -p /etc/dconf/db/${_db} || true
	echo "[${_path}]" > /etc/dconf/db/${_db}/${_settingFile}
	echo "${_setting}=${_value}" >> /etc/dconf/db/${_db}/${_settingFile}
}

# Adds a lock to a dconf setting
# $1 _path
# $2 _setting
# $3 _db
# $4 _settingFile
add_dconf_lock(){
	local _path=$1 _setting=$2 _db=$3 _settingFile=$4
	mkdir -p /etc/dconf/db/${_db}/locks
	echo "/${_path}/${_setting}" >> /etc/dconf/db/${_db}/locks/${_settingFile}
}
