#!/bin/bash
# platform = multi_platform_all
# packages = sudo

{{% if product in [ 'sle16', 'slmicro6' ] %}}
echo '# somebody ALL=/bin/ls, (!bob,alice) !/bin/cat, /bin/dog' > /usr/etc/sudoers.d/foo
{{% endif %}}
echo '#jen,!fred		ALL, !SERVERS = !/bin/sh' > /etc/sudoers
echo '# somebody ALL=/bin/ls, (!bob,alice) !/bin/cat, /bin/dog' > /etc/sudoers.d/foo
