#
# Enable restorecond for all run levels
#
/sbin/chkconfig --level 0123456 restorecond on

#
# Start restorecond if not currently running
#
/sbin/service restorecond start
