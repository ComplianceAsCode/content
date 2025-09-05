#!/bin/bash
# packages = sudo

if grep -q 'timestamp_timeout' /etc/sudoers; then
	sed -i '/.*timestamp_timeout.*/d' /etc/sudoers
fi

