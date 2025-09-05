#!/bin/bash

rm -rf /etc/ssh/ssh_config.d/*
echo "RekeyLimit 512M 1h" >> /etc/ssh/ssh_config
