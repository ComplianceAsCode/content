#!/bin/bash
# platform = Ubuntu 24.04

mkdir -p /var/log/apt
touch /var/log/apt/testfile
chown nobody /var/log/apt/testfile
