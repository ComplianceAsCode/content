#!/bin/bash
# packages = aide

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
# On Debian derivatives aide has no compiled-in configuration file location, so
# "aide --init" fails with "missing configuration". aideinit assembles the
# configuration and initializes the database, which is what the remediation does.
aideinit -y -f
{{% else %}}
aide --init
{{% endif %}}

cp "$DB_PATH/$DB_NAME_NEW" "$DB_PATH/$DB_NAME"

{{% if product in [ 'ol10', 'rhel10', 'fedora' ] %}}
DB_KEY_DEFAULT=database_in
{{% else %}}
DB_KEY_DEFAULT=database
{{% endif %}}

# aide 0.18 renamed the "database" option to "database_in" and aide 0.19 removed
# the old name, so use the key the configuration file of the distribution has.
if grep -q "^database_in=file:" "$DB_CONF"; then
    DB_KEY=database_in
elif grep -q "^database=file:" "$DB_CONF"; then
    DB_KEY=database
else
    DB_KEY=$DB_KEY_DEFAULT
fi

if grep -q "^$DB_KEY=file:" "$DB_CONF"; then
    sed -i "s#^$DB_KEY=file:.*#$DB_KEY=file:$DB_PATH/$DB_NAME#" "$DB_CONF"
else
    echo "$DB_KEY=file:$DB_PATH/$DB_NAME" >> "$DB_CONF"
fi
