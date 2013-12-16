#
# Disable rhsmcertd for all run levels
#
chkconfig --level 0123456 rhsmcertd off

#
# Stop rhsmcertd if currently running
#
service rhsmcertd stop
