#!/bin/bash
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
# packages = chrony
#

systemctl enable chronyd.service

echo "cmdport 0" >> /etc/chrony.conf

# Create the fixed chrony-wait.service override (RHEL 8 version - no hardening)
cat > /etc/systemd/system/chrony-wait.service << 'EOF'
[Unit]
Description=Wait for chrony to synchronize system clock(KCS 7064388)
Documentation=man:chronyc(1)
After=chronyd.service
Requires=chronyd.service
Before=time-sync.target
Wants=time-sync.target

[Service]
Type=oneshot
# Wait for chronyd to update the clock and the remaining
# correction to be less than 0.1 seconds
ExecStart=/usr/bin/chronyc waitsync 0 0.1 0.0 1
# Wait for at most 3 minutes
TimeoutStartSec=180
RemainAfterExit=yes
StandardOutput=null

[Install]
WantedBy=multi-user.target
EOF
