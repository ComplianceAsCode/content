#
# Disable bluetooth for all run levels
#
chkconfig --level 0123456 bluetooth off

#
# Stop bluetooth if currently running
#
service bluetooth stop
