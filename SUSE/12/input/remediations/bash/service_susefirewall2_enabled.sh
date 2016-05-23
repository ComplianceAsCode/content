# platform = SUSE Enterprise 12
#
# Enable SuSEfirewall2.service for all systemd targets
#
systemctl enable SuSEfirewall2.service

#
# Start SuSEfirewall2.service if not currently running
#
systemctl start SuSEfirewall2.service
