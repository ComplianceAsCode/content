#
# Disable telnetd for all run levels
#
/sbin/chkconfig --level 0123456 telnetd off

#
# Stop telnetd if currently running
#
/sbin/service telnetd stop 1>/dev/null
