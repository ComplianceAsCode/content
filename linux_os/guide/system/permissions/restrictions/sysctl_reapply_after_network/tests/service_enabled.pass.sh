#!/bin/bash
# platform = multi_platform_all

SERVICE_FILE="/etc/systemd/system/sysctl-reapply-network.service"

cat > "${SERVICE_FILE}" << 'EOF'
[Unit]
Description=Re-apply sysctl hardening after network interfaces come up
After=networking.service systemd-networkd.service
DefaultDependencies=no

[Service]
Type=oneshot
ExecStart=/sbin/sysctl --system
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable sysctl-reapply-network.service
