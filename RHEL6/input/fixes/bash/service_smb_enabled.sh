#
# Enable smb for all run levels
#
chkconfig --level 0123456 smb on

#
# Start smb if not currently running
#
service smb start
