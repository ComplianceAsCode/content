# platform = Red Hat Enterprise Linux 6
#
# Disable snmpd for all run levels
#
/sbin/chkconfig --level 0123456 snmpd off

#
# Stop snmpd if currently running
#
/sbin/service snmpd stop
