#!/bin/bash
mkdir -p /etc/systemd/coredump.conf.d
echo [Coredump] > /etc/systemd/coredump.conf
echo [Coredump] > /etc/systemd/coredump.conf.d/private.conf
echo Storage=none >> /etc/systemd/coredump.conf.d/private.conf
