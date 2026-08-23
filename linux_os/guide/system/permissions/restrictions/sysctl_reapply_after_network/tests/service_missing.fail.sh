#!/bin/bash
# platform = multi_platform_all

systemctl disable sysctl-reapply-network.service 2>/dev/null || true
rm -f /etc/systemd/system/sysctl-reapply-network.service
systemctl daemon-reload
