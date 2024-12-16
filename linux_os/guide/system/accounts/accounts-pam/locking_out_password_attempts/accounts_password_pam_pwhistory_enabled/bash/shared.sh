# platform = multi_platform_ubuntu

conf_name=cac_pwhistory
conf_path="/usr/share/pam-configs"

if [ ! -f "$conf_path"/"$conf_name" ]; then
    if [ -f "$conf_path"/pwhistory ]; then
        cp "$conf_path"/pwhistory "$conf_path"/"$conf_name"
        sed -i '/Default: yes/a Priority: 1025\
Conflicts: pwhistory' "$conf_path"/"$conf_name"
    else
        cat << EOF > "$conf_path"/"$conf_name"
Name: pwhistory password history checking
Default: yes
Priority: 1024
Password-Type: Primary
Password: requisite pam_pwhistory.so remember=24 enforce_for_root try_first_pass use_authtok
EOF
    fi
fi

DEBIAN_FRONTEND=noninteractive pam-auth-update
