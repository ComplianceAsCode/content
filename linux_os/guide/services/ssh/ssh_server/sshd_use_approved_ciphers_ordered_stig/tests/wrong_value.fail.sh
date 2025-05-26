#!/bin/bash

source common.sh

echo " Ciphers aes128-ctr,aes192-ctr,weak-cipher,aes128-cbc,aes192-cbc,aes256-cbc,3des-cbc,rijndael-cbc@lysator\.liu\.se" >> /etc/ssh/sshd_config
