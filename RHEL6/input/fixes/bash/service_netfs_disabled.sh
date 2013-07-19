#
# Disable netfs for all run levels
#
chkconfig --level 0123456 netfs off

#
# Stop netfs if currently running
#
service netfs stop
