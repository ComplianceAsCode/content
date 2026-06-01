# platform = Oracle Linux 8,Red Hat Enterprise Linux 8

# Fix chrony-wait.service to use Unix socket instead of network socket
# The default service uses -h 127.0.0.1,::1 which fails when cmdport is 0
# RHEL 8 version without additional hardening (KCS 7064388)
if systemctl list-unit-files chrony-wait.service >/dev/null 2>&1; then
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
    systemctl daemon-reload
    systemctl enable chrony-wait.service
fi
