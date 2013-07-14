#
# Enable nfslock for all run levels
#
chkconfig --level 0123456 nfslock on

#
# Start nfslock if not currently running
#
service nfslock start
