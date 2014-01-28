#
# Enable auditd for all run levels
#
chkconfig --level 0123456 auditd on

#
# Start auditd if not currently running
#
service auditd start
