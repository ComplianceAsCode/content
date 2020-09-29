#!/bin/bash
# packages = tftp-server


if grep -q 'server_args' /etc/xinetd.d/tftp; then
	sed -i '/.*server_args.*/d' /etc/xinetd.d/tftp
fi
