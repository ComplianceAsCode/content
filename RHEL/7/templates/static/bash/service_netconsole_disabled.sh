# platform = Red Hat Enterprise Linux 7
#
# Disable netconsole for all systemd targets
#
systemctl disable netconsole

#
# Stop netconsole if currently running
#
systemctl stop netconsole

