#!/bin/bash
# platform = Ubuntu 24.04

useradd gdm || true

mkdir -p /var/log/gdm3
chown -R root /var/log/gdm3

touch /var/log/gdm3/testfile
chown nobody /var/log/gdm3/testfile
