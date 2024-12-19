#!/bin/bash

{{% if product == "ubuntu2404" %}}
{{{ bash_pam_pwquality_enable() }}}
{{% endif %}}

echo 'enforcing = 1' > /etc/security/pwquality.conf
