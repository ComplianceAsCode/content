#!/bin/bash
# platform = Ubuntu 24.04

useradd gdm || true

mkdir -p /var/log/gdm
chown -R root /var/log/gdm

touch /var/log/gdm/testfile
chown nobody /var/log/gdm/testfile
