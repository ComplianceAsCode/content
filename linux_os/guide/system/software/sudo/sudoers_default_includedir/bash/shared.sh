# platform = multi_platform_all

sudoers_config_file="/etc/sudoers"
sudoers_config_dir="/etc/sudoers.d"
sudoers_includedir_count=$(grep -c "#includedir" "$sudoers_config_file")
if [ "$sudoers_includedir_count" -gt 1 ]; then
    sed -i "/#includedir.*/d" "$sudoers_config_file"
    echo "#includedir /etc/sudoers.d" >> "$sudoers_config_file"
elif [ "$sudoers_includedir_count" -eq 0 ]; then
    echo "#includedir /etc/sudoers.d" >> "$sudoers_config_file"
else
    if ! grep -q "^#includedir /etc/sudoers.d" "$sudoers_config_file"; then
        sed -i "s|^#includedir.*|#includedir /etc/sudoers.d|g" "$sudoers_config_file"
    fi
fi
sed -i "/^#include\s\+.*/d" "$sudoers_config_file" "${sudoers_config_dir}"/*
sed -i "/^#includedir\s\+.*/d" "${sudoers_config_dir}"/*
