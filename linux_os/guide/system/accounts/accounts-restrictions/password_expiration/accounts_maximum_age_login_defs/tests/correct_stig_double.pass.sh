#!/bin/bash
{{% if product == "ubuntu2404" %}}
# platform = Not Applicable
{{% else %}}
# profiles = xccdf_org.ssgproject.content_profile_stig
{{% endif %}}


rm -f /etc/login.defs
echo "PASS_MAX_DAYS        60" > /etc/login.defs
echo "PASS_MAX_DAYS        30" >> /etc/login.defs
