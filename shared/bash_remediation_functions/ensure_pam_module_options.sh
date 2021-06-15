function ensure_pam_module_options {
	if [ $# -lt 7 ] || [ $# -gt 8 ] ; then
                echo "$0 requires seven or eight arguments" >&2
                exit 1
        fi
	local _pamFile="$1" _type="$2" _control="$3" _module="$4" _option="$5" _valueRegex="$6" _defaultValue="$7"
	local _remove_argument=""
	if [ $# -eq 8 ] ; then
        	_remove_argument="$8"
		# convert it to lowercase
		_remove_argument=${_remove_argument,,}
	fi

	# make sure that we have a line like this in ${_pamFile} (additional options are left as-is):
	# ${_type} ${_control} ${_module} ${_option}=${_valueRegex}

	if ! [ -e "$_pamFile" ] ; then
		echo "$_pamFile doesn't exist" >&2
		exit 1
	fi

	# if remove argument only
	if [ "${_remove_argument}" = "yes" -o "${_remove_argument}" = "true" ] ; then
		sed --follow-symlinks -i -E -e "s/^(\\s*${_type}\\s+\\S+\\s+${_module}(\\s.+)?)\\s${_option}(=\\S+)?/\\1/" "${_pamFile}"
		exit 0
	fi

	# non-empty values need to be preceded by an equals sign
	[ -n "${_valueRegex}" ] && _valueRegex="=${_valueRegex}"
	# add an equals sign to non-empty values
	[ -n "${_defaultValue}" ] && _defaultValue="=${_defaultValue}"

	# fix 'type' if it's wrong
	if grep -q -P "^\\s*(?"'!'"${_type}\\s)[[:alnum:]]+\\s+[[:alnum:]]+\\s+${_module}" < "${_pamFile}" ; then
		sed --follow-symlinks -i -E -e "s/^(\\s*)[[:alnum:]]+(\\s+[[:alnum:]]+\\s+${_module})/\\1${_type}\\2/" "${_pamFile}"
	fi

	# fix 'control' if it's wrong
	if grep -q -P "^\\s*${_type}\\s+(?"'!'"${_control})[[:alnum:]]+\\s+${_module}" < "${_pamFile}" ; then
		sed --follow-symlinks -i -E -e "s/^(\\s*${_type}\\s+)[[:alnum:]]+(\\s+${_module})/\\1${_control}\\2/" "${_pamFile}"
	fi

	# fix the value for 'option' if one exists but does not match '_valueRegex'
    if grep -q -P "^\\s*${_type}\\s+${_control}\\s+${_module}(\\s.+)?\\s+${_option}(?"'!'"${_valueRegex}(\\s|\$))" < "${_pamFile}" ; then
		sed --follow-symlinks -i -E -e "s/^(\\s*${_type}\\s+${_control}\\s+${_module}(\\s.+)?\\s)${_option}=[^[:space:]]*/\\1${_option}${_defaultValue}/" "${_pamFile}"

    # add 'option=default' if option is not set
	elif grep -q -E "^\\s*${_type}\\s+${_control}\\s+${_module}" < "${_pamFile}" &&
         grep    -E "^\\s*${_type}\\s+${_control}\\s+${_module}" < "${_pamFile}" | grep -q -E -v "\\s${_option}(=|\\s|\$)" ; then

		sed --follow-symlinks -i -E -e "s/^(\\s*${_type}\\s+${_control}\\s+${_module}[^\\n]*)/\\1 ${_option}${_defaultValue}/" "${_pamFile}"
	# add a new entry if none exists
	elif ! grep -q -P "^\\s*${_type}\\s+${_control}\\s+${_module}(\\s.+)?\\s+${_option}${_valueRegex}(\\s|\$)" < "${_pamFile}" ; then
		echo "${_type} ${_control} ${_module} ${_option}${_defaultValue}" >> "${_pamFile}"
	fi
}
