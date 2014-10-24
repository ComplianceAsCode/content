#
# Disable cgred for all run levels
#
/sbin/chkconfig --level 0123456 cgred off

#
# Stop cgred if currently running
#
/sbin/service cgred stop
