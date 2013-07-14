#
# Enable sshd for all run levels
#
chkconfig --level 0123456 sshd on

#
# Start sshd if not currently running
#
service sshd start
