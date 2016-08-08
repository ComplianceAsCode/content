. /usr/share/scap-security-guide/remediation_functions
populate gui_login_banner_text

gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory --type bool --set /apps/gdm/simple-greeter/banner_message_enable true &>/dev/null
gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory --type string --set /apps/gdm/simple-greeter/banner_message_text "$(echo $gui_login_banner_text | sed -e 's/\[\\s\\n\][+|*]/ /g' -e 's/\&amp;/\&/g' -e 's/\\//g' -e 's/ - /\n- /g')" &>/dev/null
