#
# Disable tftp for all run levels
#
chkconfig --level 0123456 tftp off

#
# Stop tftp if currently running
#
service tftp stop
