#
# Enable restorecond for all run levels
#
chkconfig --level 0123456 restorecond on

#
# Start restorecond if not currently running
#
service restorecond start
