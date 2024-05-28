#!/bin/bash
# packages = rsyslog
bash -x setup.sh

echo 'global(DefaultNetstreamDriver="tftp" DefaultNetstreamDriverKeyFile="/path/to/contrib/gnutls/key.pem")' > /etc/rsyslog.conf
