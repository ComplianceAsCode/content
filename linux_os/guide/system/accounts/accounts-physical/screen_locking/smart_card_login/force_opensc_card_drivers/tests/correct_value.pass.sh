#!/bin/bash
# packages = opensc
# variables = var_smartcard_drivers=default

cat  <<EOF  > /etc/opensc.conf
app default {
	# debug = 3;
	# debug_file = opensc-debug.txt;
	framework pkcs15 {
		use_file_caching = true;
	}
	reader_driver pcsc {
		# The pinpad is disabled by default,
		# because of many broken readers out there
		enable_pinpad = false;
	}
	force_card_driver = default;
}
EOF
