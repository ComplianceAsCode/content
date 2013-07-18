#
# Disable cgconfig for all run levels
#
chkconfig --level 0123456 cgconfig off

#
# Stop cgconfig if currently running
#
service cgconfig stop
