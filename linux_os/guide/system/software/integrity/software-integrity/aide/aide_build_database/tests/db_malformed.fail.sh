#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S

# ensure aide is installed
yum install -y aide


DB=/var/lib/aide/aide.db.gz

rm -r $DB
echo "not really a database" > $DB
