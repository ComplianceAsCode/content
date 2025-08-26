#!/bin/bash
# platform = multi_platform_ubuntu

chown root -R /var/log/*

ln -s /etc/issue /var/log/test.log.symlink
chown -h nobody /var/log/test.log.symlink
