#
# Disable tftp for all run levels
#
/sbin/chkconfig --level 0123456 tftp off

#
# Stop tftp if currently running
#
/sbin/service tftp stop 1>/dev/null
