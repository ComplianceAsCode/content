#
# Disable prelinking altogether
#
sed -i "s/PRELINKING.*/PRELINKING=no/g" /etc/sysconfig/prelink

#
# Undo previous prelink changes to binaries
#
/usr/sbin/prelink -ua
