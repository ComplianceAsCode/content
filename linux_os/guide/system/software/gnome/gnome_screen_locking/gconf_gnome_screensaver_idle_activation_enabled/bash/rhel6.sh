# platform = Red Hat Enterprise Linux 6
# Install GConf2 package if not installed
if ! rpm -q GConf2; then
  yum -y install GConf2
fi

# Set the screensaver activation in the GNOME desktop after a period of inactivity
gconftool-2 --direct \
            --config-source "xml:readwrite:/etc/gconf/gconf.xml.mandatory" \
            --type bool \
            --set /apps/gnome-screensaver/idle_activation_enabled true
