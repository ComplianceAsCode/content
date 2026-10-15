#!/bin/bash
# packages = aide
# platform = multi_platform_almalinux,multi_platform_debian,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_rhv,multi_platform_ubuntu

DB_PATH=/var/lib/aide
DB_CONF={{{ aide_conf_path }}}

{{% if 'ubuntu' in product or 'debian' in product or 'sle' in product or 'slmicro' in product %}}
DB_NAME=aide.db
DB_NAME_NEW=aide.db.new
{{% else %}}
DB_NAME=aide.db.gz
DB_NAME_NEW=aide.db.new.gz
{{% endif %}}

{{% if 'ubuntu' in product or 'debian' in product %}}
aideinit -y -f
{{% else %}}
aide --init
{{% endif %}}

cp "$DB_PATH/$DB_NAME_NEW" "$DB_PATH/$DB_NAME"

if ! grep -q "^@@define[[:space:]]\+DBDIR[[:space:]]" "$DB_CONF"; then
    sed -i "1i @@define DBDIR $DB_PATH" "$DB_CONF"
fi

{{% if product in [ 'ol10', 'rhel10', 'fedora' ] %}}
DB_KEY_DEFAULT=database_in
{{% else %}}
DB_KEY_DEFAULT=database
{{% endif %}}

if grep -q "^database_in=file:" "$DB_CONF"; then
    DB_KEY=database_in
elif grep -q "^database=file:" "$DB_CONF"; then
    DB_KEY=database
else
    DB_KEY=$DB_KEY_DEFAULT
fi

if grep -q "^$DB_KEY=file:" "$DB_CONF"; then
    sed -i "s#^$DB_KEY=file:.*#$DB_KEY=file:@@{DBDIR}/$DB_NAME#" "$DB_CONF"
else
    echo "$DB_KEY=file:@@{DBDIR}/$DB_NAME" >> "$DB_CONF"
fi
