#!/bin/bash

source common.sh

echo "ciphers ${ssh_approved_ciphers},blahblah" >> /etc/ssh/ssh_config
