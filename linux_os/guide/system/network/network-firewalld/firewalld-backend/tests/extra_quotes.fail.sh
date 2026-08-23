#!/bin/bash
sed -i '/FirewallBackend/d' "/etc/firewalld/firewalld.conf"
echo "FirewallBackend='nftables'" >> "/etc/firewalld/firewalld.conf"
