#
# Disable cgconfig for all run levels
#
/sbin/chkconfig --level 0123456 cgconfig off

#
# Stop cgconfig if currently running
#
/sbin/service cgconfig stop
