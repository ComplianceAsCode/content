#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora
# packages = firewalld

systemctl stop firewalld 2>/dev/null || true
systemctl stop iptables 2>/dev/null || true
systemctl stop nftables 2>/dev/null || true
systemctl start firewalld
