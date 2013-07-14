#
# Disable portreserve for all run levels
#
chkconfig --level 0123456 portreserve off

#
# Stop portreserve if currently running
#
service portreserve stop
