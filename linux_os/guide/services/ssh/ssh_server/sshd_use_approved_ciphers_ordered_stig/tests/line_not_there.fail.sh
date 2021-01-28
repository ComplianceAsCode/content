#!/bin/bash

sed -i "/^Ciphers.*/d" /etc/ssh/sshd_config
