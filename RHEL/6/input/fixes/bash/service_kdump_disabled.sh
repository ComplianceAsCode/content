#
# Disable kdump for all run levels
#
chkconfig --level 0123456 kdump off

#
# Stop kdump if currently running
#
service kdump stop
