#!/bin/bash

echo 'global(DefaultNetstreamDriver="gtls" DefaultNetstreamDriverCAFile="/path/to/contrib/gnutls/ca.pem" DefaultNetstreamDriverCertFile="/path/to/contrib/gnutls/cert.pem" DefaultNetstreamDriverKeyFile="/path/to/contrib/gnutls/key.pem")' > /etc/rsyslog.conf
