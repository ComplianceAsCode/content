# platform = multi_platform_sle
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

#Name of the table
{{{ bash_instantiate_variables("var_nftables_table") }}}
#Familiy of the table 
{{{ bash_instantiate_variables("var_nftables_family") }}}
#Number of base chains
{{{ bash_instantiate_variables("var_nftables_base_chain_number") }}}
#Name(s) of base chain
{{{ bash_instantiate_variables("var_nftables_base_chain_names") }}}
#Type(s) of base chain
{{{ bash_instantiate_variables("var_nftables_base_chain_types") }}}
# Hooks for base chain
{{{ bash_instantiate_variables("var_nftables_base_chain_hooks") }}}
#Priority
{{{ bash_instantiate_variables("var_nftables_base_chain_priorities") }}}
#Policy 
{{{ bash_instantiate_variables("var_nftables_base_chain_policies") }}}

#We add a table if ti does not exist
IS_TABLE=$(nft list tables)
if [ -z "$IS_TABLE" ]
then
  nft create table "$var_nftables_family" "$var_nftables_table"
fi

#We add base chains
for ((i=0; i < $((var_nftables_base_chain_number)); i++)) 
do
   is_chain_exist=`nft list ruleset | grep 'hook ${var_nftables_base_chain_hooks[$i]}'`
   if [ -z "$is_chain_exist" ]
   then
      chain_to_add="add chain $var_nftables_family $var_nftables_table ${var_nftables_base_chain_names[$i]} \
      { type ${var_nftables_base_chain_types[$i]} hook ${var_nftables_base_chain_hooks[$i]} \
      priority ${var_nftables_base_chain_priorities[$i]} ; \
      policy ${var_nftables_base_chain_policies[$i]}; }"
      mycommand="nft '$chain_to_add'"
      eval $mycommand
   fi
done 
