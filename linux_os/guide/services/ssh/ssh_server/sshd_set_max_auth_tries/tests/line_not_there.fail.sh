#!/bin/bash

sed -i "/^MaxAuthTries.*/d" /etc/ssh/sshd_config
