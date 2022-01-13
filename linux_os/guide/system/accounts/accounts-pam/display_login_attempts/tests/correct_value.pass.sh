#!/bin/bash
# platform = Red Hat Enterprise Linux 7,multi_platform_ol,multi_platform_ubuntu

{{% if product in ["sle12", "sle15"] or 'ubuntu' in product %}}
rm -f /etc/pam.d/login
echo "session required pam_lastlog.so showfailed" >> /etc/pam.d/login
{{% else %}}
rm -f /etc/pam.d/postlogin
echo "session required pam_lastlog.so showfailed" >> /etc/pam.d/postlogin
{{% endif %}}
