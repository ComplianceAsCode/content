#
# Enable quota_nld for all run levels
#
chkconfig --level 0123456 quota_nld on

#
# Start quota_nld if not currently running
#
service quota_nld start
