# platform = Red Hat Enterprise Linux 7
grep -qi disable /etc/xinetd.d/rexec && \
  sed -i "s/disable.*/disable         = yes/gI" /etc/xinetd.d/rexec

#
# Disable rexec.socket for all systemd targets
#
systemctl disable rexec.socket

#
# Stop rexec.socket if currently running
#
systemctl stop rexec.socket
