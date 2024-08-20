#!/bin/bash
# packages = aide

{{% if 'ubuntu' in product or 'sle' in product or 'slmicro5' in product %}}
DB=/var/lib/aide/aide.db
{{% else %}}
DB=/var/lib/aide/aide.db.gz
{{% endif %}}

rm -rf $DB
