#!/bin/bash

echo [Coredump] > /etc/systemd/coredump.conf
echo [Coredump] > /etc/systemd/coredump.conf.d/private.conf
echo Storage=none >> /etc/systemd/coredump.conf.d/private.conf
