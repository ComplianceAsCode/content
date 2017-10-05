# platform = Red Hat Enterprise Linux 6
# Install GConf2 package if not installed
if ! rpm -q GConf2; then
  yum -y install GConf2
fi

# Enable displaying of a login warning banner in the GNOME Display Manager's
# login screen
gconftool-2 --direct \
            --config-source "xml:readwrite:/etc/gconf/gconf.xml.mandatory" \
            --type bool \
            --set /apps/gdm/simple-greeter/banner_message_enable true
