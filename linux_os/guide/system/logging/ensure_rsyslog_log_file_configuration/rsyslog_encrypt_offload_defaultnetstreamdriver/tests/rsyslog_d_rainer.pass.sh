#!/bin/bash
bash -x setup.sh

echo 'global(DefaultNetstreamDriver="gtls" DefaultNetstreamDriverCAFile="/path/to/contrib/gnutls/ca.pem" DefaultNetstreamDriverCertFile="/path/to/contrib/gnutls/cert.pem" DefaultNetstreamDriverKeyFile="/path/to/contrib/gnutls/key.pem")' > /etc/rsyslog.d/encrypt.conf
