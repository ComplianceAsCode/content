#!/bin/bash

source common.sh

echo "Ciphers $sshd_scrambled_ciphers" >> /etc/ssh/sshd_config
