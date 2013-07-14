#
# Enable cups for all run levels
#
chkconfig --level 0123456 cups on

#
# Start cups if not currently running
#
service cups start
