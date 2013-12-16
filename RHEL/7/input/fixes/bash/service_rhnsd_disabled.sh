#
# Disable rhnsd for all run levels
#
chkconfig --level 0123456 rhnsd off

#
# Stop rhnsd if currently running
#
service rhnsd stop
