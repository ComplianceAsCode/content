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

#Transfer some of strings to arrays
IFS="," read -r -a  arr_chnames <<< "$var_nftables_base_chain_names"
IFS="," read -r -a  arr_chtypes <<< "$var_nftables_base_chain_types"
IFS="," read -r -a  arr_chhooks <<< "$var_nftables_base_chain_hooks"
IFS="," read -r -a  arr_chpriorities <<< "$var_nftables_base_chain_priorities"
IFS="," read -r -a  arr_chpolicies <<< "$var_nftables_base_chain_policies"

#We add a table if it does not exist
IS_TABLE=$(nft list tables)
if [ -z "$IS_TABLE" ]
then
  nft create table "$var_nftables_family" "$var_nftables_table"
fi

#We add base chains
for ((i=0; i < $((var_nftables_base_chain_number)); i++))
do
   IS_CHAIN_EXIST=$(nft list ruleset | grep "hook ${arr_chhooks[$i]}")
   if [ -z "$IS_CHAIN_EXIST" ]
   then
      chain_to_add="add chain $var_nftables_family $var_nftables_table ${arr_chnames[$i]} { type ${arr_chtypes[$i]} hook ${arr_chhooks[$i]} priority ${arr_chpriorities[$i]} ; policy ${arr_chpolicies[$i]} ; }"
      mycommand="nft '$chain_to_add'"
      eval $mycommand
   fi
done
