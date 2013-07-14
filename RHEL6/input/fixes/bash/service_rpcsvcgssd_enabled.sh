#
# Enable rpcsvcgssd for all run levels
#
chkconfig --level 0123456 rpcsvcgssd on

#
# Start rpcsvcgssd if not currently running
#
service rpcsvcgssd start
