# platform = Red Hat Enterprise Linux 7
FSTAB=/etc/fstab
echo "/tmp     /var/tmp     none     rw,nodev,noexec,nosuid,bind     0 0" >> $FSTAB