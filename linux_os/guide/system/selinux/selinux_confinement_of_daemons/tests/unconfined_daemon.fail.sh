#!/bin/bash
#
# remediation = none

cat > /usr/bin/dummydaemon.sh << EOF
#!/bin/bash

while true; do
	date
	sleep 60
done
EOF
chmod +x /usr/bin/dummydaemon.sh

cat > /etc/systemd/system/dummydaemon.service << EOF
[Unit]
Description=Dummy daemon

[Service]
ExecStart=/usr/bin/dummydaemon.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl start dummydaemon.service
systemctl status dummydaemon.service
