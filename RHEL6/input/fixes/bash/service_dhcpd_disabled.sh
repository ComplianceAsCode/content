#
# Disable dhcpd for all run levels
#
chkconfig --level 0123456 dhcpd off

#
# Stop dhcpd if currently running
#
service dhcpd stop
