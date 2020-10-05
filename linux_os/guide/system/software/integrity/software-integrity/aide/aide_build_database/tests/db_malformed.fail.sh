#!/bin/bash
# packages = aide

# ensure aide is installed

DB=/var/lib/aide/aide.db.gz

rm -r $DB
echo "not really a database" > $DB
