#!/bin/bash
# variables = var_nftables_family=inet,var_nftables_table=filter

var_nftables_family="inet"
var_nftables_table="filter"

nft list tables |
while read table; do
	nft delete $table
done

nft create table "$var_nftables_family" "$var_nftables_table"
