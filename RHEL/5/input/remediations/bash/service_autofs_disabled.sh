#
# Disable autofs for all run levels
#
/sbin/chkconfig --level 0123456 autofs off

#
# Stop autofs if currently running
#
/sbin/service autofs stop 1>/dev/null
