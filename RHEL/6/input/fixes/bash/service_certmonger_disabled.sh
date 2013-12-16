#
# Disable certmonger for all run levels
#
chkconfig --level 0123456 certmonger off

#
# Stop certmonger if currently running
#
service certmonger stop
