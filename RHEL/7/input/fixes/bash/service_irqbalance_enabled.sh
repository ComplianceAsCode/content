#
# Enable irqbalance.service for all systemd targets
#
systemctl enable irqbalance.service

#
# Start irqbalance.service if not currently running
#
systemctl start irqbalance.service
