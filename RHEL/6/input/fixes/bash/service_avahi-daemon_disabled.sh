#
# Disable avahi-daemon for all run levels
#
chkconfig --level 0123456 avahi-daemon off

#
# Stop avahi-daemon if currently running
#
service avahi-daemon stop
