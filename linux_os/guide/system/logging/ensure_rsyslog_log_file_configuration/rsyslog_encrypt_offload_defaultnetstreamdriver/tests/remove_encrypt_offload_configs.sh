#!/bin/bash

# Function to remove all cron entries from /etc/rsyslog.conf and /etc/rsyslog.d/
function remove_encrypt_offload_configs {
	# remove DefaultNetstreamDriver entries
	sed -i '/^[[:space:]]*\$DefaultNetstreamDriver/d' /etc/rsyslog.conf
	find /etc/rsyslog.d -type f -name "*.conf" -exec sed -i '/^[[:space:]]*\$DefaultNetstreamDriver/d' {} +
	# remove all multilined and onelined RainerScript entries
	sed -i '/^[[:space:]]*global\(/ { :a; N; /\)/!ba; /DefaultNetstreamDriver/d }' /etc/rsyslog.conf 
	find /etc/rsyslog.d -type f -name "*.conf" -exec sed -i '/^[[:space:]]*global\(/ { :a; N; /\)/!ba; /DefaultNetstreamDriver/d }' {} +
}
