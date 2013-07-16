#
# Enable crond for all run levels
#
chkconfig --level 0123456 crond on

#
# Stop crond if currently running
#
service crond start
