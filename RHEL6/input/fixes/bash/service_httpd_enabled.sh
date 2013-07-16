#
# Enable httpd for all run levels
#
chkconfig --level 0123456 httpd on

#
# Start httpd if not currently running
#
service httpd start
