#!/bin/bash
# platform = Red Hat Enterprise Linux CoreOS 4
# remediation = none
#
# On RHCOS4 one unconfined_service_t process (kubelet) is allowed. A second
# unconfined daemon next to it must still fail the rule.

cat > /usr/local/bin/kubelet << 'EOF'
#!/bin/bash

while true; do
	sleep 60
done
EOF
chmod +x /usr/local/bin/kubelet

cat > /usr/bin/dummydaemon.sh << 'EOF'
#!/bin/bash

while true; do
	sleep 60
done
EOF
chmod +x /usr/bin/dummydaemon.sh

for unit in mock-kubelet:/usr/local/bin/kubelet dummydaemon:/usr/bin/dummydaemon.sh; do
	cat > "/etc/systemd/system/${unit%%:*}.service" << EOF
[Unit]
Description=${unit%%:*} for testing

[Service]
Type=simple
ExecStart=${unit#*:}
SELinuxContext=system_u:system_r:unconfined_service_t:s0
Restart=no

[Install]
WantedBy=multi-user.target
EOF
done

systemctl daemon-reload
systemctl start mock-kubelet.service dummydaemon.service

# Wait for the services to start
sleep 2

exit 0
