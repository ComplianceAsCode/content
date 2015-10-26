# platform = Red Hat Enterprise Linux 6
#
# Disable sshd for all run levels
#
/sbin/chkconfig --level 0123456 sshd off

#
# Stop sshd if currently running
#
/sbin/service sshd stop
