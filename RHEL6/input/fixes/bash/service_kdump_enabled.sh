#
# Enable kdump for all run levels
#
chkconfig --level 0123456 kdump on

#
# Start kdump if not currently running
#
service kdump start
