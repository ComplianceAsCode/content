# platform = Red Hat Enterprise Linux 10

# The RHEL 10 STIG prescribes the arch-split rules without a syscall filter,
# with the privileged-passwd audit key
grep -q -- '-a always,exit -F arch=b32 -F path=/usr/bin/passwd -F perm=x -k privileged-passwd' /etc/audit/rules.d/audit.rules || \
    echo '-a always,exit -F arch=b32 -F path=/usr/bin/passwd -F perm=x -k privileged-passwd' >> /etc/audit/rules.d/audit.rules
grep -q -- '-a always,exit -F arch=b64 -F path=/usr/bin/passwd -F perm=x -k privileged-passwd' /etc/audit/rules.d/audit.rules || \
    echo '-a always,exit -F arch=b64 -F path=/usr/bin/passwd -F perm=x -k privileged-passwd' >> /etc/audit/rules.d/audit.rules
grep -q -- '-a always,exit -F arch=b32 -F path=/usr/bin/passwd -F perm=x -k privileged-passwd' /etc/audit/audit.rules || \
    echo '-a always,exit -F arch=b32 -F path=/usr/bin/passwd -F perm=x -k privileged-passwd' >> /etc/audit/audit.rules
grep -q -- '-a always,exit -F arch=b64 -F path=/usr/bin/passwd -F perm=x -k privileged-passwd' /etc/audit/audit.rules || \
    echo '-a always,exit -F arch=b64 -F path=/usr/bin/passwd -F perm=x -k privileged-passwd' >> /etc/audit/audit.rules
