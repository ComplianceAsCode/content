# platform = multi_platform_all

source common.sh

if grep -q '^\s*hosts:' "$NSSWITCHFILE"; then
    sed -i 's/^\s*hosts:.*$/& dns/g' "$NSSWITCHFILE"
else
    echo "hosts: dns" >> "$NSSWITCHFILE"
fi

echo -e "#nameserver 192.168.1.2\n#nameserver 192.168.1.3\n" >> "$RESOLVFILE"
