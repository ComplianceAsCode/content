#
# Enable nfs for all run levels
#
chkconfig --level 0123456 nfs on

#
# Start nfs if not currently running
#
service nfs start
