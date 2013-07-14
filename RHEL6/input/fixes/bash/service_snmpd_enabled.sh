#
# Enable snmpd for all run levels
#
chkconfig --level 0123456 snmpd on

#
# Start snmpd if not currently running
#
service snmpd start
