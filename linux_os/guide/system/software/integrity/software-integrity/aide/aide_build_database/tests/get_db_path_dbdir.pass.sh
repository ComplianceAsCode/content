#!/bin/bash
# packages = aide

aide --init

{{% if 'ubuntu' in product or 'sle' in product or 'slmicro' in product %}}
DB_NAME=aide.db.new
DB_CONF=/etc/aide/aide.conf
{{% else %}}
DB_NAME=aide.db.new.gz
DB_CONF=/etc/aide.conf
{{% endif %}}

{{% if product in [ 'ol10', 'rhel10', 'fedora' ] %}}
sed -i "s#^database_in=file:.*#database_in=file:@@{DBDIR}/$DB_NAME#" $DB_CONF
{{% else %}}
sed -i "s#^database=file:.*#database=file:@@{DBDIR}/$DB_NAME#" $DB_CONF
{{% endif %}}
