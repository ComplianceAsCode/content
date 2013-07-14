#
# Enable dhcpd for all run levels
#
chkconfig --level 0123456 dhcpd on

#
# Start dhcpd if not currently running
#
service dhcpd start
