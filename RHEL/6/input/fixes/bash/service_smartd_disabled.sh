#
# Disable smartd for all run levels
#
chkconfig --level 0123456 smartd off

#
# Stop smartd if currently running
#
service smartd stop
