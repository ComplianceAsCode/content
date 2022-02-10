# platform = multi_platform_all

sudoers_config_file="/etc/sudoers"
sudoers_includedir_count=$(grep -c "#includedir" "$sudoers_config_file")
if [ "$sudoers_includedir_count" -gt 1 ]; then
    sed -i "/#includedir.*/d" "$sudoers_config_file"
    echo "#includedir /etc/sudoers.d" >> "$sudoers_config_file"
elif [ "$sudoers_includedir_count" -eq 0 ]; then
    echo "#includedir /etc/sudoers.d" >> "$sudoers_config_file"
else
    if ! grep -q "^#includedir /etc/sudoers.d" /etc/sudoers; then
        sed -i "s|^#includedir.*|#includedir /etc/sudoers.d|g" /etc/sudoers
    fi
fi
