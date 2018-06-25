# Function to enable/disable and start/stop services on RHEL and Fedora systems.
#
# Example Call(s):
#
#     service_command enable bluetooth
#
#     Using xinetd:
#     service_command disable rsh xinetd=rsh
#
SYSTEMCTL_EXEC='/usr/bin/systemctl'
SERVICE_EXEC='/sbin/service'
CHKCONFIG_EXEC='/sbin/chkconfig'


function xinetd_disable {
	sed -i "s/disable.*/disable         = no/gI" "/etc/xinetd.d/$1"
}


function xinetd_enable {
	sed -i "s/disable.*/disable         = yes/gI" "/etc/xinetd.d/$1"
}


function systemd_disable {
	local service_stem="$1"
	"$SYSTEMCTL_EXEC" stop "$service_stem".service
	"$SYSTEMCTL_EXEC" disable "$service_stem".service
	# Disable socket activation if we have a unit file for it
	"$SYSTEMCTL_EXEC" list-unit-files | grep -q "^$service_stem\\>".socket && "$SYSTEMCTL_EXEC" disable "$service_stem".socket
	# The service may not be running because it has been started and failed,
	# so let's reset the state so OVAL checks pass.
	# Service should be 'inactive', not 'failed' after reboot though.
	"$SYSTEMCTL_EXEC" reset-failed "$service_stem".service
}


function systemd_enable {
	local service_stem="${1%%.*}"
	"$SYSTEMCTL_EXEC" start "$service_stem".service
	"$SYSTEMCTL_EXEC" enable "$service_stem".service
}


function chkconfig_disable {
	"$SERVICE_EXEC" "$1" disable
	"$CHKCONFIG_EXEC" --level 0123456 "$1" off
}


function chkconfig_enable {
	"$SERVICE_EXEC" "$1" enable
	"$CHKCONFIG_EXEC" --level 0123456 "$1" on
}


function service_command {
	# Load function arguments into local variables
	local service_state=$1 service=$2 xinetd
	xinetd=$(echo "$3" | cut -d'=' -f2)

	# Check sanity of the input
	if [ $# -lt "2" ]; then
		echo "Usage: service_command 'enable/disable' 'service_name.service'"
		echo
		echo "To enable or disable xinetd services add \\'xinetd=service_name\\'"
		echo "as the last argument"
		echo "Aborting."
		exit 1
	fi

	test "$service_state" = enable || test "$service_state" = disable || { echo "The service state has to be either 'enable' or 'disable', got '$service_state'"; return 1; }

	# If systemctl is installed, use systemctl command; otherwise, use the service/chkconfig commands
	# foo_$service_state => foo_disabled / foo_enabled
	if test -f "/usr/bin/systemctl"; then
		"systemd_$service_state" "$service"
	else
		"chkconfig_$service_state" "$service"
	fi

	test "x$xinetd" != x || "xinetd_$service_state" "$xinetd"
}
