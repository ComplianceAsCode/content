#
# Enable vsftpd for all run levels
#
chkconfig --level 0123456 vsftpd on

#
# Start vsftpd if not currently running
#
service vsftpd start
