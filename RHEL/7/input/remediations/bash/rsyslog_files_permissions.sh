# platform = Red Hat Enterprise Linux 7

# List of log file paths to be inspected for correct permissions
# * Primarily inspect log file paths listed in /etc/rsyslog.conf
RSYSLOG_ETC_CONFIG="/etc/rsyslog.conf"
# * And also the log file paths listed after rsyslog's $IncludeConfig directive
RSYSLOG_INCLUDE_CONFIG=$(grep -e "\$IncludeConfig[[:space:]]\+[^[:space:];]\+" /etc/rsyslog.conf | cut -d ' ' -f 2)
# Declare an array to hold the final list of different log file paths
declare -a LOG_FILE_PATHS

# Browse each file selected above as containing paths of log files
# ('/etc/rsyslog.conf' and '/etc/rsyslog.d/*.conf' in the default configuration)
for LOG_FILE in "$RSYSLOG_ETC_CONFIG" "$RSYSLOG_INCLUDE_CONFIG"
do
	# From each of these files extract just particular log file path(s), thus:
	# * Ignore lines starting with space (' '), comment ('#"), or variable syntax ('$') characters,
	# * Ignore empty lines,
	# * From the remaining valid rows select only fields constituting a log file path
	# Text file column is understood to represent a log file path if and only if all of the following are met:
	# * it contains at least one slash '/' character,
	# * it doesn't contain space (' '), colon (':'), and semicolon (';') characters
	#
	# IMPORTANT NOTE: The $LOG_FILE variable in the next statement is intentionally kept unquoted!!!
	#		  To properly handle the case when rsyslog's $IncludeConfig directive value
	#		  would contain glob expression in order this glob to be expanded to all possible log file names.
	#
	MATCHED_ITEMS=$(sed -e "/^[[:space:]|#|$]/d ; s/[^\/]*[[:space:]]*\([^:;[:space:]]*\)/\1/g ; /^$/d" $LOG_FILE)
	# Since above sed command might return more than one item (delimited by newline), split the particular
	# matches entries into new array specific for this log file
	readarray -t ARRAY_FOR_LOG_FILE <<< "$MATCHED_ITEMS"
	# Concatenate the two arrays - previous content of $LOG_FILE_PATHS array with
	# items from newly created array for this log file
	LOG_FILE_PATHS=("${LOG_FILE_PATHS[@]}" "${ARRAY_FOR_LOG_FILE[@]}")
	# Delete the temporary array
	unset ARRAY_FOR_LOG_FILE
done

for PATH in "${LOG_FILE_PATHS[@]}"
do

	# Sanity check - if particular $PATH is empty string, skip it from further processing
	if [ -z "$PATH" ]
	then
		continue
	fi
	# Per https://access.redhat.com/solutions/66805 '/var/log/boot.log' log file needs special care => perform it
	if [ "$PATH" == "/var/log/boot.log" ]
	then
		# Ensure permissions of /var/log/boot.log are configured to be updated in /etc/rc.local
		if ! /usr/bin/grep -q "boot.log" "/etc/rc.local"
		then
			echo "chmod 600 /var/log/boot.log" >> /etc/rc.local
		fi
		# Ensure /etc/rc.d/rc.local has user-executable permission
		# (in order to be actually executed during boot)
		if [ "$(/usr/bin/stat -c %a /etc/rc.d/rc.local)" -ne 744 ]
		then
			/usr/bin/chmod u+x /etc/rc.d/rc.local
		fi
	# For any other log file just check if its permissions differ from 600. If so, correct them
	else
		if [ "$(/usr/bin/stat -c %a "$PATH")" -ne 600 ]
		then
			chmod 600 "$PATH"
		fi
	fi
done
