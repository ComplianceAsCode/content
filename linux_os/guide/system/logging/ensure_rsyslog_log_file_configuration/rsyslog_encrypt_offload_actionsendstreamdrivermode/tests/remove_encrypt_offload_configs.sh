#!/bin/bash

# Function to remove all cron entries from /etc/rsyslog.conf and /etc/rsyslog.d/
function remove_encrypt_offload_configs {
	# remove ActionSendStreamDriverMode entries
	sed -i '/^[[:space:]]*\$ActionSendStreamDriverMode/d' /etc/rsyslog.conf
	find /etc/rsyslog.d -type f -name "*.conf" -exec sed -i '/^[[:space:]]*\$ActionSendStreamDriverMode/d' {} +
	# remove all multilined and onelined RainerScript entries
	sed -i '/^[[:space:]]*action(/,/)/d' /etc/rsyslog.conf 
	find /etc/rsyslog.d -type f -name "*.conf" -exec sed -i '/^[[:space:]]*action(/,/)/d' {} +
}
