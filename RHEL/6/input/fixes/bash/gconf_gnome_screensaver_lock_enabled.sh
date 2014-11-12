# Install GConf2 package if not installed
rpm -q GConf2
if ! [ $? -eq 0 ]
then
  yum -y install GConf2
fi

# Set the screensaver locking activation in the GNOME desktop when the
# screensaver is activated
gconftool-2 --direct \
            --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
            --type bool \
            --set /apps/gnome-screensaver/lock_enabled true
