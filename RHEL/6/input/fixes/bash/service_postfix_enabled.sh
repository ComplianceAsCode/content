#
# Enable postfix for all run levels
#
chkconfig --level 0123456 postfix on

#
# Start postfix if not currently running
#
service postfix start
