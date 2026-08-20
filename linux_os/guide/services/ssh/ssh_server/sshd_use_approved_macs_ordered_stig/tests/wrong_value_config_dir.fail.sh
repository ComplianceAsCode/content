#!/bin/bash

source common.sh

echo "MACs ${sshd_approved_macs},weak-hmac" >> /etc/ssh/sshd_config.d/test.conf
