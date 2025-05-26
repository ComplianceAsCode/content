#!/bin/bash

source common.sh

echo "MACs $sshd_scrambled_macs" >> /etc/ssh/sshd_config
