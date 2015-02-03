#
# Disable httpd for all run levels
#
/sbin/chkconfig --level 0123456 httpd off

#
# Stop httpd if currently running
#
/sbin/service httpd stop
