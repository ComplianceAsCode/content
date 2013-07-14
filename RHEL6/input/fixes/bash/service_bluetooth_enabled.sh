#
# Enable bluetooth for all run levels
#
chkconfig --level 0123456 bluetooth on

#
# Start bluetooth if not currently running
#
service bluetooth start
