#
# Enable auditd for all run levels
#
chkconfig --level 0123456 auditd on

#
# Stop auditd if currently running
#
service auditd start
