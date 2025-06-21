#!/bin/bash
# packages = aide

# This TS is a regression test for https://bugzilla.redhat.com/show_bug.cgi?id=2175684

{{% if 'ubuntu' in product or 'sle' in product or 'slmicro' in product %}}
DB_NEW=/var/lib/aide/aide.db.new
DB=/var/lib/aide/aide.db
{{% else %}}
DB_NEW=/var/lib/aide/aide.db.new.gz
DB=/var/lib/aide/aide.db.gz
{{% endif %}}

aide --init
cp "$DB_NEW" "$DB"
rm -rf "$DB_NEW"
