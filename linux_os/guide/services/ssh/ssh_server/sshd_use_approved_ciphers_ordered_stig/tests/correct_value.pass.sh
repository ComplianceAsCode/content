#!/bin/bash

source common.sh

echo "ciphers $sshd_approved_ciphers" >> /etc/ssh/sshd_config
