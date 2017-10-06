# platform = Red Hat Enterprise Linux 6
# platform = Red Hat Enterprise Linux 6
# Install GConf2 package if not installed
if ! rpm -q GConf2; then
  yum -y install GConf2
fi

# Disable displaying of all known system users in the GNOME Display Manager's
# login screen
gconftool-2 --direct \
            --config-source "xml:readwrite:/etc/gconf/gconf.xml.mandatory" \
            --type bool \
            --set /apps/gdm/simple-greeter/disable_user_list true
