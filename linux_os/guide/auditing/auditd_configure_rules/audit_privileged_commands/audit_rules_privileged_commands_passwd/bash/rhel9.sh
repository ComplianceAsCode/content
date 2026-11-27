# platform = Red Hat Enterprise Linux 9

# The RHEL 9 STIG prescribes the arch-split rules without a syscall filter
grep -q -- '-a always,exit -F arch=b32 -F path=/usr/bin/passwd -F perm=x -k identity' /etc/audit/rules.d/audit.rules || \
    echo '-a always,exit -F arch=b32 -F path=/usr/bin/passwd -F perm=x -k identity' >> /etc/audit/rules.d/audit.rules
grep -q -- '-a always,exit -F arch=b64 -F path=/usr/bin/passwd -F perm=x -k identity' /etc/audit/rules.d/audit.rules || \
    echo '-a always,exit -F arch=b64 -F path=/usr/bin/passwd -F perm=x -k identity' >> /etc/audit/rules.d/audit.rules
grep -q -- '-a always,exit -F arch=b32 -F path=/usr/bin/passwd -F perm=x -k identity' /etc/audit/audit.rules || \
    echo '-a always,exit -F arch=b32 -F path=/usr/bin/passwd -F perm=x -k identity' >> /etc/audit/audit.rules
grep -q -- '-a always,exit -F arch=b64 -F path=/usr/bin/passwd -F perm=x -k identity' /etc/audit/audit.rules || \
    echo '-a always,exit -F arch=b64 -F path=/usr/bin/passwd -F perm=x -k identity' >> /etc/audit/audit.rules
