#
# Disable kdump for all run levels
#
/sbin/chkconfig --level 0123456 kdump off

#
# Stop kdump if currently running
#
/sbin/service kdump stop
