#!/bin/bash

#Set name of the table
var_nftables_table='filter'

#Set familiy of the table 
var_nftables_family='inet'

#Set name(s) of base chain
var_nftables_base_chain_names='input,forward,output'

#Set type(s) of base chain
var_nftables_base_chain_types='filter,filter,filter'

#Set hooks for base chain
var_nftables_base_chain_hooks='input,forward,output'

#Set priority
var_nftables_base_chain_priorities='0,0,0'

#Set policy 
var_nftables_base_chain_policies='accept,accept,accept'

#Transfer some of strings to arrays
IFS="," read -r -a  names <<< "$var_nftables_base_chain_names"
IFS="," read -r -a  types <<< "$var_nftables_base_chain_types"
IFS="," read -r -a  hooks <<< "$var_nftables_base_chain_hooks"
IFS="," read -r -a  priorities <<< "$var_nftables_base_chain_priorities"
IFS="," read -r -a  policies <<< "$var_nftables_base_chain_policies"

# Remove everything 
nft flush ruleset

# We create a table and add chains to it
nft create table "$var_nftables_family" "$var_nftables_table"
num_of_chains=${#names[@]}
for ((i=0; i < num_of_chains; i++))
  do
   chain_to_add="add chain $var_nftables_family $var_nftables_table ${names[$i]} { type ${types[$i]} hook ${hooks[$i]} priority ${priorities[$i]} ; policy ${policies[$i]} ; }"
   mycommand="nft '$chain_to_add'"
   eval $mycommand
done   
