#
# Disable ypbind for all run levels
#
chkconfig --level 0123456 ypbind off

#
# Stop ypbind if currently running
#
service ypbind stop
