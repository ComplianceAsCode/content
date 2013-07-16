#
# Disable vsftpd for all run levels
#
chkconfig --level 0123456 vsftpd off

#
# Stop vsftpd if currently running
#
service vsftpd stop
