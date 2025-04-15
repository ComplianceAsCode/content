#!/bin/bash

source common.sh

echo "MACs $sshd_approved_macs" >> /etc/ssh/sshd_config
