#!/bin/bash

source common.sh

echo "ciphers ${sshd_approved_ciphers},blahblah" >> /etc/ssh/sshd_config
