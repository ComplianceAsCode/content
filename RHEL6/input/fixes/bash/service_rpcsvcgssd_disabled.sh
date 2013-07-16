#
# Disable rpcsvcgssd for all run levels
#
chkconfig --level 0123456 rpcsvcgssd off

#
# Stop rpcsvcgssd if currently running
#
service rpcsvcgssd stop
