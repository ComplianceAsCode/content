# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle

# List of log file paths to be inspected for correct permissions
# * Primarily inspect log file paths listed in /etc/rsyslog.conf
RSYSLOG_ETC_CONFIG="/etc/rsyslog.conf"
# * And also the log file paths listed after rsyslog's $IncludeConfig directive
#   (store the result into array for the case there's shell glob used as value of IncludeConfig)
readarray -t OLD_INC < <(grep -e "\$IncludeConfig[[:space:]]\+[^[:space:];]\+" /etc/rsyslog.conf | cut -d ' ' -f 2)
readarray -t RSYSLOG_INCLUDE_CONFIG < <(for INCPATH in "${OLD_INC[@]}"; do eval printf '%s\\n' "${INCPATH}"; done)
readarray -t NEW_INC < <(awk '/)/{f=0} /include\(/{f=1} f{nf=gensub("^(include\\(|\\s*)file=\"(\\S+)\".*","\\2",1); if($0!=nf){print nf}}' /etc/rsyslog.conf)
readarray -t RSYSLOG_INCLUDE < <(for INCPATH in "${NEW_INC[@]}"; do eval printf '%s\\n' "${INCPATH}"; done)

# Declare an array to hold the final list of different log file paths
declare -a LOG_FILE_PATHS

# Array to hold all rsyslog config entries
RSYSLOG_CONFIGS=()
RSYSLOG_CONFIGS=("${RSYSLOG_ETC_CONFIG}" "${RSYSLOG_INCLUDE_CONFIG[@]}" "${RSYSLOG_INCLUDE[@]}")

# Get full list of files to be checked
# RSYSLOG_CONFIGS may contain globs such as
# /etc/rsyslog.d/*.conf /etc/rsyslog.d/*.frule
# So, loop over the entries in RSYSLOG_CONFIGS and use find to get the list of included files.
RSYSLOG_CONFIG_FILES=()
for ENTRY in "${RSYSLOG_CONFIGS[@]}"
do
	# If directory, rsyslog will search for config files in recursively.
	# However, files in hidden sub-directories or hidden files will be ignored.
	if [ -d "${ENTRY}" ]
	then
		readarray -t FINDOUT < <(find "${ENTRY}" -not -path '*/.*' -type f)
		RSYSLOG_CONFIG_FILES+=("${FINDOUT[@]}")
	elif [ -f "${ENTRY}" ]
	then
		RSYSLOG_CONFIG_FILES+=("${ENTRY}")
	else
		echo "Invalid include object: ${ENTRY}"
	fi
done

# Browse each file selected above as containing paths of log files
# ('/etc/rsyslog.conf' and '/etc/rsyslog.d/*.conf' in the default configuration)
for LOG_FILE in "${RSYSLOG_CONFIG_FILES[@]}"
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
		NORMALIZED_CONFIG_FILE_LINES=$(sed -e "/^[#|$]/d" "${LOG_FILE}")
		LINES_WITH_PATHS=$(grep '[^/]*\s\+\S*/\S\+$' <<< "${NORMALIZED_CONFIG_FILE_LINES}")
		FILTERED_PATHS=$(awk '{if(NF>=2&&($2~/^\//||$2~/^-\//)){sub(/^-\//,"/",$2);print $2}}' <<< "${LINES_WITH_PATHS}")
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
{{% if product in ["debian9", "debian10", "debian11", "ubuntu1604", "ubuntu1804", "ubuntu2004", "ubuntu2204", "sle15", "sle12"] %}}
DESIRED_PERM_MOD=640
{{% else %}}
DESIRED_PERM_MOD=600
{{% endif %}}
# Correct the form o
for LOG_FILE_PATH in "${LOG_FILE_PATHS[@]}"
do
	# Sanity check - if particular $LOG_FILE_PATH is empty string, skip it from further processing
	if [ -z "$LOG_FILE_PATH" ]
	then
		continue
	fi

	# Also for each log file check if its permissions differ from 600. If so, correct them
	if [ -f "$LOG_FILE_PATH" ] && [ "$(/usr/bin/stat -c %a "$LOG_FILE_PATH")" -ne $DESIRED_PERM_MOD ]
	then
		/bin/chmod $DESIRED_PERM_MOD "$LOG_FILE_PATH"
	fi
done
