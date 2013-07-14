#
# Enable haldaemon for all run levels
#
chkconfig --level 0123456 haldaemon on

#
# Start haldaemon if not currently running
#
service haldaemon start
