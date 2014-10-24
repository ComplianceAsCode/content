#
# Disable quota_nld for all run levels
#
/sbin/chkconfig --level 0123456 quota_nld off

#
# Stop quota_nld if currently running
#
/sbin/service quota_nld stop
