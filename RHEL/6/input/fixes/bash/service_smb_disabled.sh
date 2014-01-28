#
# Disable smb for all run levels
#
chkconfig --level 0123456 smb off

#
# Stop smb if currently running
#
service smb stop
