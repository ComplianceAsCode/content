# Function to add cron logging line to specific file
# Expects argument:
# file:		Configuration file, where we want cron logging set
#
function set_cron_logging {
	local file=$1

	if grep -s '^[[:space:]]*cron\.\*' "$file"; then
		sed -i 's|^\([[:space:]]*cron\.\*[[:space:]]+\).*|\1/var/log/cron|' $file
	else
		echo 'cron.*    /var/log/cron' >> $file
	fi
}
