# platform = multi_platform_ubuntu
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

config_file=/etc/apt/apt.conf.d/99-cis-repository-security
option='Acquire::AllowWeakRepositories'
setting='Acquire::AllowWeakRepositories "0";'

touch "$config_file"

# Drop the option everywhere it is already set, so a conflicting value in
# another APT configuration file cannot re-enable it.
while IFS= read -r -d '' apt_conf_file; do
    sed -ri "/^[[:space:]]*${option}[[:space:]]+/Id" "$apt_conf_file"
done < <(find /etc/apt/apt.conf /etc/apt/apt.conf.d -maxdepth 1 -type f -print0 2>/dev/null)

if [ -s "$config_file" ] && [ -n "$(tail -c 1 "$config_file")" ]; then
    printf '\n' >> "$config_file"
fi
printf '%s\n' "$setting" >> "$config_file"
