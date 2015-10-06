# platform = Red Hat Enterprise Linux 6
#
# Enable auditd for all run levels
#
/sbin/chkconfig --level 0123456 auditd on

#
# Start auditd if not currently running
#
/sbin/service auditd start
