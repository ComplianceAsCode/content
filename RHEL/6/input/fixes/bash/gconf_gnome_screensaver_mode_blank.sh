# Install GConf2 package if not installed
rpm -q GConf2
if ! [ $? -eq 0 ]
then
  yum -y install GConf2
fi

# Set the screensaver mode in the GNOME desktop to a blank screen
gconftool-2 --direct \
            --config-source "xml:readwrite:/etc/gconf/gconf.xml.mandatory" \
            --type string \
            --set /apps/gnome-screensaver/mode blank-only
