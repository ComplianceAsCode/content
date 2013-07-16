#
# Enable acpid for all run levels
#
chkconfig --level 0123456 acpid on

#
# Start acpid if not currently running
#
service acpid start
