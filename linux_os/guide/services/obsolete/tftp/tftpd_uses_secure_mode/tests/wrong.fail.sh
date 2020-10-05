#!/bin/bash
# packages = tftp-server


if grep -q 'server_args' /etc/xinetd.d/tftp; then
	sed -i 's/.*server_args.*/server_args = --something/' /etc/xinetd.d/tftp
else
	echo "server_args = --something" >> /etc/xinetd.d/tftp
fi
