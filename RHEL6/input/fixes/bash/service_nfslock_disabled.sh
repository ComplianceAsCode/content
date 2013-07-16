#
# Disable nfslock for all run levels
#
chkconfig --level 0123456 nfslock off

#
# Stop nfslock if currently running
#
service nfslock stop
