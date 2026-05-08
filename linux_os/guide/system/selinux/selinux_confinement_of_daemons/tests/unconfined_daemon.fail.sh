#!/bin/bash
#
# remediation = none

cat > /usr/bin/dummydaemon.sh << 'EOF'
#!/bin/bash

while true; do
	date
	sleep 60
done
EOF
chmod +x /usr/bin/dummydaemon.sh

cat > /etc/systemd/system/dummydaemon.service << 'EOF'
[Unit]
Description=Dummy daemon

[Service]
Type=simple
ExecStart=/usr/bin/dummydaemon.sh
Restart=no

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start dummydaemon.service

# Wait a moment for service to start
sleep 2

# Exit cleanly - the OVAL check should detect an unconfined daemon and fail
exit 0
