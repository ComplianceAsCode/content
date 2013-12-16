#
# Disable quota_nld for all run levels
#
chkconfig --level 0123456 quota_nld off

#
# Stop quota_nld if currently running
#
service quota_nld stop
