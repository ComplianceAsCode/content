#!/bin/bash
{{% if "ubuntu" in product %}}
# packages = auditd
{{% else %}}
# packages = audit
{{% endif %}}

source common.sh

echo "log_group = root" >> /etc/audit/auditd.conf

chgrp root ${FILE1}
chgrp group_test ${FILE2}
