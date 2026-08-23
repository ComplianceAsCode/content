#!/bin/bash
# platform = multi_platform_all

touch /etc/sysctl.conf
ln -sf /etc/sysctl.conf /etc/sysctl.d/99-sysctl.conf
