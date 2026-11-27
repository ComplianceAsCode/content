#!/bin/bash
# packages = aide

# This TS is a regression test for https://bugzilla.redhat.com/show_bug.cgi?id=2175684

{{% if 'ubuntu' in product or 'debian' in product or 'sle' in product or 'slmicro' in product %}}
DB_NEW=/var/lib/aide/aide.db.new
DB=/var/lib/aide/aide.db
{{% else %}}
DB_NEW=/var/lib/aide/aide.db.new.gz
DB=/var/lib/aide/aide.db.gz
{{% endif %}}
DB_CONF={{{ aide_conf_path }}}

{{% if 'ubuntu' in product or 'debian' in product %}}
aideinit -y -f
{{% else %}}
aide --init
{{% endif %}}

cp "$DB_NEW" "$DB"
rm -rf "$DB_NEW"

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

grep -q "^$DB_KEY=file:" "$DB_CONF" || echo "$DB_KEY=file:$DB" >> "$DB_CONF"
