#
# Disable snmpd for all run levels
#
chkconfig --level 0123456 snmpd off

#
# Stop snmpd if currently running
#
service snmpd stop
