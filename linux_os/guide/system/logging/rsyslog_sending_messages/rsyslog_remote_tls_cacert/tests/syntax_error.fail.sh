#!/bin/bash
# remediation = none
{{% if product in ["fedora", "rhel10" ] %}}
{{# https://fedoraproject.org/wiki/Changes/dropingOfCertPemFile #}}
{{% set cafile = "/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem" %}}
{{% else %}}
{{% set cafile = "/etc/pki/tls/cert.pem" %}}
{{% endif %}}
echo 'global(DefaultNetstreamDriverCAFile="{{{ cafile }}}") *.*' >> /etc/rsyslog.conf
