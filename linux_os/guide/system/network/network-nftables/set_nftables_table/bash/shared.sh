# platform = multi_platform_all

#Set nftables family name
{{{ bash_instantiate_variables("var_nftables_family") }}}

#Set nftables table name
{{{ bash_instantiate_variables("var_nftables_table") }}}

IS_TABLE=$(nft list tables)
if [ -z "$IS_TABLE" ]
then
  nft create table "$var_nftables_family" "$var_nftables_table"
fi
