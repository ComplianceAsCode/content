# platform = multi_platform_ubuntu
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

config_file=/etc/apt/apt.conf.d/99-cis-repository-security
setting='Acquire::AllowWeakRepositories "0";'
touch "$config_file"
sed -ri '/^[[:space:]]*Acquire::AllowWeakRepositories[[:space:]]+/d' "$config_file"
if [ -s "$config_file" ] && [ -n "$(tail -c 1 "$config_file")" ]; then
    printf '\n' >> "$config_file"
fi
printf '%s\n' "$setting" >> "$config_file"
