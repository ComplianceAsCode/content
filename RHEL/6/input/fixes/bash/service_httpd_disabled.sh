#
# Disable httpd for all run levels
#
chkconfig --level 0123456 httpd off

#
# Stop httpd if currently running
#
service httpd stop
