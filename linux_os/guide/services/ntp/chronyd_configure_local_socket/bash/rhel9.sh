# platform = Oracle Linux 9,Red Hat Enterprise Linux 9,Red Hat Enterprise Linux 10,multi_platform_almalinux,multi_platform_fedora

# Fix chrony-wait.service to use Unix socket instead of network socket
# The default service uses -h 127.0.0.1,::1 which fails when cmdport is 0
# RHEL 9+ version with hardening directives (KCS 7064388)
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

CapabilityBoundingSet=~CAP_AUDIT_CONTROL CAP_AUDIT_READ CAP_AUDIT_WRITE
CapabilityBoundingSet=~CAP_BLOCK_SUSPEND CAP_KILL CAP_LEASE CAP_LINUX_IMMUTABLE
CapabilityBoundingSet=~CAP_MAC_ADMIN CAP_MAC_OVERRIDE CAP_MKNOD CAP_SYS_ADMIN
CapabilityBoundingSet=~CAP_SYS_BOOT CAP_SYS_CHROOT CAP_SYS_MODULE CAP_SYS_PACCT
CapabilityBoundingSet=~CAP_SYS_PTRACE CAP_SYS_RAWIO CAP_SYS_TTY_CONFIG CAP_WAKE_ALARM
DevicePolicy=closed
#DynamicUser=yes
IPAddressAllow=localhost
IPAddressDeny=any
LockPersonality=yes
MemoryDenyWriteExecute=yes
PrivateDevices=yes
ProcSubset=pid
ProtectClock=yes
ProtectControlGroups=yes
ProtectHome=yes
ProtectHostname=yes
ProtectKernelLogs=yes
ProtectKernelModules=yes
ProtectKernelTunables=yes
ProtectProc=invisible
ProtectSystem=strict
RestrictAddressFamilies=AF_UNIX
RestrictNamespaces=yes
RestrictRealtime=yes
SystemCallArchitectures=native
SystemCallFilter=@system-service
SystemCallFilter=~@privileged @resources
UMask=0777

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable chrony-wait.service
fi
