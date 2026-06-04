# platform = multi_platform_debian
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

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

chown root:root "${SERVICE_FILE}"
chmod 0644 "${SERVICE_FILE}"

systemctl daemon-reload
systemctl enable sysctl-reapply-network.service

if [[ $(systemctl is-system-running) != "offline" ]]; then
    systemctl start sysctl-reapply-network.service
fi
