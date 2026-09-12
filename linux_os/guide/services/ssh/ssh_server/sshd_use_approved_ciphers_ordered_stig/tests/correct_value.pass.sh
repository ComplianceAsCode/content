#!/bin/bash

source common.sh

echo "Ciphers $sshd_approved_ciphers" >> /etc/ssh/sshd_config
