#!/bin/bash
# remediation = none

echo 'global(DefaultNetstreamDriverCAFile="/etc/pki/tls/cert.pem") *.*' >> /etc/rsyslog.conf
