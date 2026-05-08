#!/bin/bash
#
# This test simulates kubelet running with unconfined_service_t (OCP 4.12 scenario)

# Create a mock kubelet process that will run as unconfined_service_t
cat > /usr/local/bin/mock-kubelet << 'EOF'
#!/bin/bash
while true; do
    sleep 3600
done
EOF
chmod +x /usr/local/bin/mock-kubelet

# Create systemd service
cat > /etc/systemd/system/mock-kubelet.service << 'EOF'
[Unit]
Description=Mock Kubelet Service

[Service]
Type=simple
ExecStart=/usr/local/bin/mock-kubelet
Restart=no

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start mock-kubelet.service

# Wait for service to start
sleep 2

# Exit cleanly - the OVAL check should pass because kubelet is excluded
# Note: In test environments without SELinux enforcing, this tests the OVAL logic
exit 0
