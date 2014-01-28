#
# Disable xinetd for all run levels
#
chkconfig --level 0123456 xinetd off

#
# Stop xinetd if currently running
#
service xinetd stop
