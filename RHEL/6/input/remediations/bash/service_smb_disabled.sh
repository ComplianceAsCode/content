# platform = Red Hat Enterprise Linux 6
#
# Disable smb for all run levels
#
/sbin/chkconfig --level 0123456 smb off

#
# Stop smb if currently running
#
/sbin/service smb stop
