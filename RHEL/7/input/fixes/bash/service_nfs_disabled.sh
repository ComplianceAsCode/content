#
# Disable nfs for all run levels
#
chkconfig --level 0123456 nfs off

#
# Stop nfs if currently running
#
service nfs stop
