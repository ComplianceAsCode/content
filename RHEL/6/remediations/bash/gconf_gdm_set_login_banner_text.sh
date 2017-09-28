# platform = Red Hat Enterprise Linux 6
. /usr/share/scap-security-guide/remediation_functions
populate login_banner_text

# Install GConf2 package if not installed
if ! rpm -q GConf2; then
  yum -y install GConf2
fi

# Expand the login_banner_text value - there was a regular-expression
# matching various banners, needs to be expanded
banner_expanded=$(echo "$login_banner_text" | sed 's/\[\\s\\n\][*+]/ /g;s/\\//g;')

# Set the text shown by the GNOME Display Manager in the login screen
gconftool-2 --direct \
            --config-source "xml:readwrite:/etc/gconf/gconf.xml.mandatory" \
            --type string \
            --set /apps/gdm/simple-greeter/banner_message_text "${banner_expanded}"
