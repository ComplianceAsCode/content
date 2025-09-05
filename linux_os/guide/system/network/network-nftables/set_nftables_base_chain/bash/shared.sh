# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

#Name of the table
{{{ bash_instantiate_variables("var_nftables_table") }}}
#Familiy of the table 
{{{ bash_instantiate_variables("var_nftables_family") }}}
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

#Transfer some of strings to arrays
IFS="," read -r -a  names <<< "$var_nftables_base_chain_names"
IFS="," read -r -a  types <<< "$var_nftables_base_chain_types"
IFS="," read -r -a  hooks <<< "$var_nftables_base_chain_hooks"
IFS="," read -r -a  priorities <<< "$var_nftables_base_chain_priorities"
IFS="," read -r -a  policies <<< "$var_nftables_base_chain_policies"

my_cmd="nft list tables | grep '$var_nftables_family $var_nftables_table'"
eval IS_TABLE_EXIST=\$\($my_cmd\)
if [ -z "$IS_TABLE_EXIST" ]
then
  # We create a table and add chains to it 
  nft create table "$var_nftables_family" "$var_nftables_table"
  num_of_chains=${#names[@]}
  for ((i=0; i < num_of_chains; i++))
  do
   chain_to_add="add chain $var_nftables_family $var_nftables_table ${names[$i]} { type ${types[$i]} hook ${hooks[$i]} priority ${priorities[$i]} ; policy ${policies[$i]} ; }"
   my_cmd="nft '$chain_to_add'"
   eval $my_cmd
  done    
else
  # We add missing chains to the existing table
  num_of_chains=${#names[@]}
  for ((i=0; i < num_of_chains; i++))
  do
    IS_CHAIN_EXIST=$(nft list table "$var_nftables_family" "$var_nftables_table" | grep "hook ${hooks[$i]}")
    if [ -z "$IS_CHAIN_EXIST" ]
      then
        chain_to_add="add chain '$var_nftables_family' '$var_nftables_table' ${names[$i]} { type ${types[$i]} hook ${hooks[$i]} priority ${priorities[$i]} ; policy ${policies[$i]} ; }"
        my_cmd="nft '$chain_to_add'"
        eval $my_cmd
    fi
  done 
fi
