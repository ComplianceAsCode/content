#
# Disable cgred for all run levels
#
chkconfig --level 0123456 cgred off

#
# Stop cgred if currently running
#
service cgred stop
