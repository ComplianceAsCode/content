# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

readarray -t world_writable_files < <(find / -xdev -type f -perm -0002 2> /dev/null)
readarray -t interactive_home_dirs < <(awk -F':' '{ if ($3 >= 1000 && $3 != 65534) print $6 }' /etc/passwd)

for world_writable in "${world_writable_files[@]}"; do
    for homedir in "${interactive_home_dirs[@]}"; do
        if grep -q -d skip "$world_writable" "$homedir"/.*; then
            chmod o-w $world_writable
            break
        fi
    done
done
