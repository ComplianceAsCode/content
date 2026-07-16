#!/bin/bash
# platform = multi_platform_debian,multi_platform_fedora,multi_platform_ubuntu
# packages = ufw

systemctl stop iptables 2>/dev/null || true
systemctl stop nftables 2>/dev/null || true
systemctl stop ufw 2>/dev/null || true
systemctl start ufw
