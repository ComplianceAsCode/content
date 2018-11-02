# platform =  multi_platform_fedora

function remediate() {
	CONFIG_FILE="/etc/named.conf"
	if test -f "$CONFIG_FILE"; then
		sed -i 's|options {|&\n\tinclude "/etc/crypto-policies/back-ends/bind.config";|' "$CONFIG_FILE"
		return 0
	else
		echo "Aborting remediation as '$CONFIG_FILE' was not even found." >&2
		return 1
	fi
}

remediate
