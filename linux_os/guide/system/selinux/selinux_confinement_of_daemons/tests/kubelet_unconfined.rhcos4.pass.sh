#!/bin/bash
#
# This test verifies that kubelet is allowed to run with unconfined_service_t on RHCOS4.
# On RHCOS4, kubelet is explicitly allowed to be unconfined.

# Create a mock kubelet binary with unconfined_service_t
# The binary name must be "kubelet" to match the OVAL pattern
cat > /usr/local/bin/kubelet << 'EOF'
#!/bin/bash

while true; do
	sleep 60
done
EOF
chmod +x /usr/local/bin/kubelet

cat > /etc/systemd/system/mock-kubelet.service << 'EOF'
[Unit]
Description=Mock kubelet for testing

[Service]
Type=simple
ExecStart=/usr/local/bin/kubelet
SELinuxContext=system_u:system_r:unconfined_service_t:s0
Restart=no

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start mock-kubelet.service

# Wait for service to start
sleep 2

# Exit cleanly - the OVAL check should allow kubelet to be unconfined and pass
exit 0
