# platform =  multi_platform_fedora,Red Hat Enterprise Linux 8,Oracle Linux 8,Red Hat Virtualization 4

function remediate_bind_crypto_policy() {
	CONFIG_FILE="/etc/named.conf"
	if test -f "$CONFIG_FILE"; then
		sed -i 's|options {|&\n\tinclude "/etc/crypto-policies/back-ends/bind.config";|' "$CONFIG_FILE"
		return 0
	else
		echo "Aborting remediation as '$CONFIG_FILE' was not even found." >&2
		return 1
	fi
}

remediate_bind_crypto_policy
