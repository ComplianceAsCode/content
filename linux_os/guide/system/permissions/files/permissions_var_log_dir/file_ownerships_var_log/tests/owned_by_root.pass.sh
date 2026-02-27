#!/bin/bash
# platform = multi_platform_ubuntu

chown root -R /var/log/*

touch /var/log/test.log
chown root /var/log/test.log
