# platform = multi_platform_all

SSH_CONF="{{{ sshd_sysconfig_file }}}"

{{% if product == "rhel8" %}}
# Replace an uncommented 'CRYPTO_POLICY' assignment with the commented directive
# so that the SSH daemon uses the systemwide crypto policy.
sed -i "s/^\s*CRYPTO_POLICY\s*=.*$/# CRYPTO_POLICY=/I" "$SSH_CONF"

# Ensure the commented directive is present even when no assignment was set.
if ! grep -q "CRYPTO_POLICY" "$SSH_CONF"; then
    echo "# CRYPTO_POLICY=" >> "$SSH_CONF"
fi

# Restart 'sshd' so the change takes effect; skip when systemd is not running,
# for example in containers.
if [[ $(/usr/bin/systemctl is-system-running) != "offline" ]]; then
    /usr/bin/systemctl restart sshd.service
fi
{{% else %}}
sed -i "/^\s*CRYPTO_POLICY.*$/Id" $SSH_CONF
{{% endif %}}
