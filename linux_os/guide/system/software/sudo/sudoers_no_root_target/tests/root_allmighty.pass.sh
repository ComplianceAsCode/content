#!/bin/bash
# platform = multi_platform_all
# packages = sudo

# Allow root to execute commands on behalf of anybody
echo ' root ALL=(ALL) ALL' > /etc/sudoers
echo 'root ALL= ALL' >> /etc/sudoers
echo '# user ALL= ALL' >> /etc/sudoers
# add fail line in /usr/etc/sudoers, it should not be checked
# when /etc/sudoers
{{% if product in [ 'sle16', 'slmicro6' ] %}}
echo 'user ALL=(ALL) ALL' > /usr/etc/sudoers
{{% endif %}}
