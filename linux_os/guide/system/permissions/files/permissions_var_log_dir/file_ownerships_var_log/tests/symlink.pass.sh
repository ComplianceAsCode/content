#!/bin/bash
# platform = Ubuntu 24.04

chown root -R /var/log/*

ln -s /etc/issue /var/log/test.log.symlink
chown -h nobody /var/log/test.log.symlink
