# platform = multi_platform_sle

#Set nftables family name
{{{ bash_instantiate_variables("var_nftables_family") }}}
NETWORK_LEVEL=$var_nftables_family

#Set nftables table name
{{{ bash_instantiate_variables("var_nftables_table") }}} 
TABLE_NAME=$var_nftables_table

IS_TABLE=$(nft list tables)
if [ -z "$IS_TABLE" ]
then
  nft create table "$NETWORK_LEVEL" "$TABLE_NAME"
fi
