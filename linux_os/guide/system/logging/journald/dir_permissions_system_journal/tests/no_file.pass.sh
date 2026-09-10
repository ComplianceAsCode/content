#!/bin/bash
# platform = multi_platform_ubuntu

mkdir -p /run/log/journal /var/log/journal
rm -rf /run/log/journal/* /var/log/journal/*
chmod 2750 /run/log/journal /var/log/journal
