# platform = multi_platform_ubuntu
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

config_file=/etc/apt/apt.conf.d/99-cis-repository-security
option='Acquire::Check-Date'
option_pattern='(Acquire::)?Check-Date'
setting='Acquire::Check-Date "true";'

touch "$config_file"

# Remove existing definitions before writing the required value. Otherwise,
# APT file precedence could leave a conflicting definition in effect.
while IFS= read -r -d '' apt_conf_file; do
    sed -ri "/^[[:space:]]*${option_pattern}[[:space:]]+/Id" "$apt_conf_file"
done < <(find /etc/apt/apt.conf /etc/apt/apt.conf.d -maxdepth 1 -type f -print0 2>/dev/null)

if [ -s "$config_file" ] && [ -n "$(tail -c 1 "$config_file")" ]; then
    printf '\n' >> "$config_file"
fi
printf '%s\n' "$setting" >> "$config_file"
