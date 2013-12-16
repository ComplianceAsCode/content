#
# Disable atd for all run levels
#
chkconfig --level 0123456 atd off

#
# Stop atd if currently running
#
service atd stop
