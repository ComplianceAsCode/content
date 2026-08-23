#!/bin/bash

source common.sh

echo "# ciphers $ssh_approved_ciphers" >> /etc/ssh/ssh_config
