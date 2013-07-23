#
# Enable crond for all run levels
#
chkconfig --level 0123456 crond on

#
# Start crond if not currently running
#
service crond start
