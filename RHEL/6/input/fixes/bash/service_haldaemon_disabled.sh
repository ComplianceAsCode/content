#
# Disable haldaemon for all run levels
#
/sbin/chkconfig --level 0123456 haldaemon off

#
# Stop haldaemon if currently running
#
/sbin/service haldaemon stop
