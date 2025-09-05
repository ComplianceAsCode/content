#!/bin/bash
# platform = multi_platform_sle
# packages = nftables

source common.sh
# fill in inet filter with just policy drop
cat >/etc/nftables/inet-filter <<EOF
! /usr/sbin/nft -f

table inet filter {
	chain input		{ type filter hook input priority 0; policy drop ;}
	chain forward		{ type filter hook forward priority 0; policy drop ;}
	chain output		{ type filter hook output  priority 0; policy drop ;}
}

EOF
