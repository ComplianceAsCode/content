#
# Enable postfix for all run levels
#
chkconfig --level 0123456 postfix on

#
# Stop postfix if currently running
#
service postfix start
