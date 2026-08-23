#!/bin/bash

source common.sh

echo "Ciphers $ssh_scrambled_ciphers" >> /etc/ssh/ssh_config
echo "ciphers $ssh_approved_ciphers" >> /etc/ssh/ssh_config.d/00-correct.conf
