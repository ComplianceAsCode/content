# platform = Red Hat Virtualization 4,multi_platform_rhel,multi_platform_ol

SSSD_CONF="/etc/sssd/sssd.conf"
SSSD_CONF_DIR="/etc/sssd/conf.d/*.conf"

if [ ! -f "$SSSD_CONF" ] && [ ! -f "$SSSD_CONF_DIR" ]; then
    mkdir /etc/sssd
    touch "$SSSD_CONF"
fi

# Flag to check if there is already services with pam
service_already_exist=false
for f in $SSSD_CONF $SSSD_CONF_DIR; do
	if [ ! -e "$f" ]; then
		continue
	fi
	# finds all services entries under [sssd] configuration category, get a unique list so it doesn't add redundant fix
	services_list=$( awk '/^\s*\[/{f=0} /^\s*\[sssd\]/{f=1}f' $f | grep -P '^services[ \t]*=' | uniq )
    if [ -z "$services_list" ]; then
        continue
    fi

	while IFS= read -r services; do
		if [[ ! $services =~ "pam" ]]; then
			sed -i "s/$services$/&, pam/" $f
		fi
        # Either pam service was already there or got added now
        service_already_exist=true
	done <<< "$services_list"

done

# If there was no service in [sssd], add it to first config
if [ "$service_already_exist" = false ]; then
    for f in $SSSD_CONF $SSSD_CONF_DIR; do
        cat << EOF >> "$f"
[sssd]
services = pam
EOF
        break
    done
fi
