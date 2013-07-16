#
# Enable cgconfig for all run levels
#
chkconfig --level 0123456 cgconfig on

#
# Start cgconfig if not currently running
#
service cgconfig start
