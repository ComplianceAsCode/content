# platform = Red Hat Enterprise Linux 6
. /usr/share/scap-security-guide/remediation_functions
populate inactivity_timeout_value

# Install GConf2 package if not installed
if ! rpm -q GConf2; then
  yum -y install GConf2
fi

# Set the idle time-out value for inactivity in the GNOME desktop to meet the
# requirement
gconftool-2 --direct \
            --config-source "xml:readwrite:/etc/gconf/gconf.xml.mandatory" \
            --type int \
            --set /desktop/gnome/session/idle_delay ${inactivity_timeout_value}
