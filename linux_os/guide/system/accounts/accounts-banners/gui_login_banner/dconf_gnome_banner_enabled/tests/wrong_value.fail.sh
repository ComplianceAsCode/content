#!/bin/bash
# packages = dconf,gdm

{{%- if 'ubuntu' in product %}}
cat > /etc/gdm3/greeter.dconf-defaults <<EOF
[org/gnome/login-screen]
banner-message-enable=false
EOF

{{%- else %}}
source $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed

clean_dconf_settings
add_dconf_setting "org/gnome/login-screen" "banner-message-enable" "false" "{{{ dconf_gdm_dir }}}" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "banner-message-enable" "{{{ dconf_gdm_dir }}}" "00-security-settings"

dconf update
{{%- endif %}}
