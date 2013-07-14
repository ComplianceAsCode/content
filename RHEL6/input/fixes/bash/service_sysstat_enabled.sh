#
# Enable sysstat for all run levels
#
chkconfig --level 0123456 sysstat on

#
# Start sysstat if not currently running
#
service sysstat start
