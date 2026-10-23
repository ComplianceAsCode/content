# platform = multi_platform_ubuntu

{{{ bash_package_install("aide") }}}

AIDE_CONFIG=/etc/aide/aide.conf
DEFAULT_DB_PATH=/var/lib/aide/aide.db

{{% if product == 'ubuntu2204' %}}
{{%- set aide_db_key = 'database' %}}
{{% else %}}
{{%- set aide_db_key = 'database_in' %}}
{{% endif %}}

if ! grep -q '^database\(_in\)\?=file:' ${AIDE_CONFIG}; then
    # replace_or_append gets confused by 'database=file' as a key, so should not be used.
    #replace_or_append "${AIDE_CONFIG}" '^database=file' "${DEFAULT_DB_PATH}" '@CCENUM@' '%s:%s'
    echo "{{{ aide_db_key }}}=file:${DEFAULT_DB_PATH}" >> ${AIDE_CONFIG}
fi

# Fix db out path in the config file, if necessary
if ! grep -q '^database_out=file:' ${AIDE_CONFIG}; then
    echo "database_out=file:${DEFAULT_DB_PATH}.new" >> ${AIDE_CONFIG}
fi

/usr/sbin/aideinit -y -f
