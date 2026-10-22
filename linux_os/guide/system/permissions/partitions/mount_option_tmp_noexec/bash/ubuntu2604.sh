# platform = Ubuntu 26.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

tmp_unit="tmp.mount"
mount_option="noexec"
current_options=""

if ! systemctl is-active --quiet "$tmp_unit"; then
    echo "$tmp_unit is not active; the remediation cannot preserve its mount options." >&2
else
    current_options=$(systemctl show "$tmp_unit" --property=Options --value)
    if [[ -z "$current_options" ]]; then
        echo "$tmp_unit does not report its mount options." >&2
    fi
fi

if [[ -n "$current_options" && ",$current_options," != *",$mount_option,"* ]]; then
    drop_in_dir="/etc/systemd/system/${tmp_unit}.d"
    drop_in_file="${drop_in_dir}/99-cis-noexec.conf"

    install -d -m 0755 "$drop_in_dir"
    printf '[Mount]\nOptions=%s,%s\n' "$current_options" "$mount_option" > "$drop_in_file"
    chmod 0644 "$drop_in_file"

    systemctl daemon-reload
    mount --options "remount,$mount_option" --target /tmp
fi
