#!/bin/bash

# Function to remove all cron entries from /etc/rsyslog.conf and /etc/rsyslog.d/
function remove_cron_logging {
	# remove all multilined cron.* entries
	sed -i '/^[[:space:]]*cron\.\*.*action(/,/)/d' /etc/rsyslog.conf
	find /etc/rsyslog.d -type f -name "*.conf" -exec sed -i '/^[[:space:]]*cron\.\*.*action(/,/)/d' {} +
	# remove all legacy format and one line cron.* entries
	sed -i '/^[[:space:]]*cron\.\*/d' /etc/rsyslog.conf
	find /etc/rsyslog.d -type f -name "*.conf" -exec sed -i '/^[[:space:]]*cron\.\*/d' {} +
}
