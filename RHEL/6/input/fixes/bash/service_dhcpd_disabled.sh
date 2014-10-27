#
# Disable dhcpd for all run levels
#
/sbin/chkconfig --level 0123456 dhcpd off

#
# Stop dhcpd if currently running
#
/sbin/service dhcpd stop
