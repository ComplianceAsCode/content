#!/bin/bash
{{% if 'suse' in families %}}
# platform = Not Applicable
{{% else %}}
# platform = multi_platform_all
{{% endif %}}

echo "Match something" >> /etc/ssh/sshd_config
echo "Include /etc/ssh/sshd_config.d/*.conf" >> /etc/ssh/sshd_config
