#!/bin/bash
# packages = aide

aide --init
DB_PATH=/var/lib/aide

{{% if 'ubuntu' in product or 'sle' in product or 'slmicro' in product %}}
DB_NAME=aide.db
DB_NAME_NEW=aide.db.new
DB_CONF=/etc/aide/aide.conf
{{% else %}}
DB_NAME=aide.db.gz
DB_NAME_NEW=aide.db.new.gz
DB_CONF=/etc/aide.conf
{{% endif %}}

cp "$DB_PATH/$DB_NAME_NEW" "$DB_PATH/$DB_NAME"


AIDE_VERSION=$(aide -v | grep -oP 'aide \K[0-9]+\.[0-9]+')
if [ "$(echo "$AIDE_VERSION >= 0.17" | bc -l)" -eq 1 ]; then
    AIDE_DB__KEY="database_in"
else
    AIDE_DB_IN_KEY="database"
fi
sed -i "s#^${AIDE_DB_IN_KEY}=file:.*#${AIDE_DB_IN_KEY}=file:@@{DBDIR}/$DB_NAME#" $DB_CONF
