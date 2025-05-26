#!/bin/bash
# remediation = none

{{% if 'ubuntu' in product %}}
echo 'export PATH="/usr/local/sbin:..:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin"' >> /etc/environment
{{% else %}}
echo 'export PATH="/usr/local/sbin:..:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin"' >> /etc/bashrc
{{% endif %}}
