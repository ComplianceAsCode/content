#
# Disable sshd for all run levels
#
chkconfig --level 0123456 sshd off

#
# Stop sshd if currently running
#
service sshd stop
