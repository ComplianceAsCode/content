#!/bin/bash
# packages = aide

aide --init
DB_PATH=/var/lib/aide
DB_CONF={{{ aide_conf_path }}}

{{% if 'ubuntu' in product or 'sle' in product or 'slmicro' in product %}}
DB_NAME=aide.db
DB_NAME_NEW=aide.db.new
{{% else %}}
DB_NAME=aide.db.gz
DB_NAME_NEW=aide.db.new.gz
{{% endif %}}

cp "$DB_PATH/$DB_NAME_NEW" "$DB_PATH/$DB_NAME"

{{% if product in [ 'ol10', 'rhel10', 'fedora' ] %}}
sed -i "s#^database_in=file:.*#database_in=file:$DB_PATH/$DB_NAME#" $DB_CONF
{{% else %}}
sed -i "s#^database=file:.*#database=file:$DB_PATH/$DB_NAME#" $DB_CONF
{{% endif %}}
