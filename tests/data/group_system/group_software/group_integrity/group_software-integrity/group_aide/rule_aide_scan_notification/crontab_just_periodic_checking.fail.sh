#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

# ensure aide is installed
yum install -y aide

# configured in crontab
echo '0 5 * * * root /usr/sbin/aide  --check' >> /etc/crontab
