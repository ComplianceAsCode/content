# platform = multi_platform_rhel,multi_platform_ol,multi_platform_fedora

# List of log file paths to be inspected for correct permissions
# * Primarily inspect log file paths listed in /etc/rsyslog.conf
RSYSLOG_ETC_CONFIG="/etc/rsyslog.conf"
# * And also the log file paths listed after rsyslog's $IncludeConfig directive
#   (store the result into array for the case there's shell glob used as value of IncludeConfig)
readarray -t RSYSLOG_INCLUDE_CONFIG < <(grep -e "\$IncludeConfig[[:space:]]\+[^[:space:];]\+" /etc/rsyslog.conf | cut -d ' ' -f 2)
# Declare an array to hold the final list of different log file paths
declare -a LOG_FILE_PATHS

# Browse each file selected above as containing paths of log files
# ('/etc/rsyslog.conf' and '/etc/rsyslog.d/*.conf' in the default configuration)
for LOG_FILE in "${RSYSLOG_ETC_CONFIG}" "${RSYSLOG_INCLUDE_CONFIG[@]}"
do
	# From each of these files extract just particular log file path(s), thus:
	# * Ignore lines starting with space (' '), comment ('#"), or variable syntax ('$') characters,
	# * Ignore empty lines,
	# * Strip quotes and closing brackets from paths.
	# * Ignore paths that match /dev|/etc.*\.conf, as those are paths, but likely not log files
	# * From the remaining valid rows select only fields constituting a log file path
	# Text file column is understood to represent a log file path if and only if all of the following are met:
	# * it contains at least one slash '/' character,
	# * it is preceded by space
	# * it doesn't contain space (' '), colon (':'), and semicolon (';') characters
	# Search log file for path(s) only in case it exists!
	if [[ -f "${LOG_FILE}" ]]
	then
		NORMALIZED_CONFIG_FILE_LINES=$(sed -e "/^[[:space:]|#|$]/d" "${LOG_FILE}")
		LINES_WITH_PATHS=$(grep '[^/]*\s\+\S*/\S\+' <<< "${NORMALIZED_CONFIG_FILE_LINES}")
		FILTERED_PATHS=$(sed -e 's/[^\/]*[[:space:]]*\([^:;[:space:]]*\)/\1/g' <<< "${LINES_WITH_PATHS}")
		CLEANED_PATHS=$(sed -e "s/[\"')]//g; /\\/etc.*\.conf/d; /\\/dev\\//d" <<< "${FILTERED_PATHS}")
		MATCHED_ITEMS=$(sed -e "/^$/d" <<< "${CLEANED_PATHS}")
		# Since above sed command might return more than one item (delimited by newline), split the particular
		# matches entries into new array specific for this log file
		readarray -t ARRAY_FOR_LOG_FILE <<< "$MATCHED_ITEMS"
		# Concatenate the two arrays - previous content of $LOG_FILE_PATHS array with
		# items from newly created array for this log file
		LOG_FILE_PATHS+=("${ARRAY_FOR_LOG_FILE[@]}")
		# Delete the temporary array
		unset ARRAY_FOR_LOG_FILE
	fi
done

for LOG_FILE_PATH in "${LOG_FILE_PATHS[@]}"
do
	# Sanity check - if particular $LOG_FILE_PATH is empty string, skip it from further processing
	if [ -z "$LOG_FILE_PATH" ]
	then
		continue
	fi

	{{% if product == "rhel6" %}}
	# Per https://access.redhat.com/solutions/66805 '/var/log/boot.log' log file needs special care => perform it
	# This has been fixed in RHEL7, the workaround is only necessary for RHEL6
	if [ "$LOG_FILE_PATH" == "/var/log/boot.log" ]
	then
		# Ensure permissions of /var/log/boot.log are configured to be updated in /etc/rc.local
		if ! /bin/grep -q "boot.log" "/etc/rc.local"
		then
			echo "/bin/chmod 600 /var/log/boot.log" >> /etc/rc.local
		fi
		# Ensure /etc/rc.d/rc.local has user-executable permission
		# (in order to be actually executed during boot)
		if [ "$(/usr/bin/stat -c %a /etc/rc.d/rc.local)" -ne 744 ]
		then
			/bin/chmod u+x /etc/rc.d/rc.local
		fi
	fi
	{{% endif %}}

	# Also for each log file check if its permissions differ from 600. If so, correct them
	if [ -f "$LOG_FILE_PATH" ] && [ "$(/usr/bin/stat -c %a "$LOG_FILE_PATH")" -ne 600 ]
	then
		/bin/chmod 600 "$LOG_FILE_PATH"
	fi
done
