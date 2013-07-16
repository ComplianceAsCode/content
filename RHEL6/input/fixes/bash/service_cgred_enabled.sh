#
# Enable cgred for all run levels
#
chkconfig --level 0123456 cgred on

#
# Start cgred if not currently running
#
service cgred start
