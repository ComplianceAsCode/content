#
# Disable vsftpd for all run levels
#
/sbin/chkconfig --level 0123456 vsftpd off

#
# Stop vsftpd if currently running
#
/sbin/service vsftpd stop
