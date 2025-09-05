#!/bin/bash
# packages = aide

DB=/var/lib/aide/aide.db.gz

rm -rf $DB
echo "not really a database" > $DB
