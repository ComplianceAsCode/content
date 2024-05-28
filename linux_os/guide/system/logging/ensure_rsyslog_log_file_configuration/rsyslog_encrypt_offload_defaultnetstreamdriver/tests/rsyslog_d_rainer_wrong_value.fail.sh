#!/bin/bash
bash -x setup.sh

echo 'global(DefaultNetstreamDriver="tftp" DefaultNetstreamDriverKeyFile="/path/to/contrib/gnutls/key.pem")' > /etc/rsyslog.d/encrypt.conf
