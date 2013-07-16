#
# Enable restorecond for all run levels
#
chkconfig --level 0123456 restorecond on

#
# Stop restorecond if currently running
#
service restorecond start
