#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = none

echo 'global(DefaultNetstreamDriverCAFile="/etc/pki/tls/cert.pem") *.*' >> /etc/rsyslog.conf
