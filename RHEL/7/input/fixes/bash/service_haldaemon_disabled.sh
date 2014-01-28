#
# Disable haldaemon for all run levels
#
chkconfig --level 0123456 haldaemon off

#
# Stop haldaemon if currently running
#
service haldaemon stop
