#!/bin/bash
# packages = sudo

# Remove Defaults timestamp_timeout from /etc/sudoers
if grep -q 'timestamp_timeout' /etc/sudoers; then
	sed -i '/.*timestamp_timeout.*/d' /etc/sudoers
fi

# Remove Defaults timestamp_timeout from /etc/sudoers.d/00-complianceascode-test.conf
if grep -q 'timestamp_timeout' /etc/sudoers.d/00-complianceascode-test.conf; then
	sed -i '/.*timestamp_timeout.*/d' /etc/sudoers.d/00-complianceascode-test.conf
fi
