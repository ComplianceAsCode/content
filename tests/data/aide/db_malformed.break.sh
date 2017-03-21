#!/bin/bash
DB=/var/lib/aide/aide.db.gz

rm -r $DB
echo "not really a database" > $DB
