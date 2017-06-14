# platform = Red Hat Enterprise Linux 5
gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory --type int --set /apps/gnome-screensaver/idle_delay 15 &>/dev/null
