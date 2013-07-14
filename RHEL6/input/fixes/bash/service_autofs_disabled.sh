#
# Disable autofs for all run levels
#
chkconfig --level 0123456 autofs off

#
# Stop autofs if currently running
#
service autofs stop
