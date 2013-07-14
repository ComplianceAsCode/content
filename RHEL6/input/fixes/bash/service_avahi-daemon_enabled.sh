#
# Enable avahi-daemon for all run levels
#
chkconfig --level 0123456 avahi-daemon on

#
# Start avahi-daemon if not currently running
#
service avahi-daemon start
