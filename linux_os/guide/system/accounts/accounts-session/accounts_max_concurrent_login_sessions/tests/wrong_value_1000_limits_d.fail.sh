#!/bin/bash
mkdir -p /etc/security/limits.d/
echo "* hard maxlogins 1000" >> /etc/security/limits.d/limits.conf
