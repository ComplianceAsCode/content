# platform = Red Hat Enterprise Linux 6
#
# Disable avahi-daemon for all run levels
#
/sbin/chkconfig --level 0123456 avahi-daemon off

#
# Stop avahi-daemon if currently running
#
/sbin/service avahi-daemon stop
