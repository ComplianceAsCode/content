# platform = Red Hat Enterprise Linux 9

# The RHEL 9 STIG prescribes the arch-split rules with the execve syscall
# filter; the checktext requires the filter although the fixtext omits it
grep -q -- '-a always,exit -F arch=b32 -S execve -F path=/usr/bin/gpasswd -F perm=x -k identity' /etc/audit/rules.d/audit.rules || \
    echo '-a always,exit -F arch=b32 -S execve -F path=/usr/bin/gpasswd -F perm=x -k identity' >> /etc/audit/rules.d/audit.rules
grep -q -- '-a always,exit -F arch=b64 -S execve -F path=/usr/bin/gpasswd -F perm=x -k identity' /etc/audit/rules.d/audit.rules || \
    echo '-a always,exit -F arch=b64 -S execve -F path=/usr/bin/gpasswd -F perm=x -k identity' >> /etc/audit/rules.d/audit.rules
grep -q -- '-a always,exit -F arch=b32 -S execve -F path=/usr/bin/gpasswd -F perm=x -k identity' /etc/audit/audit.rules || \
    echo '-a always,exit -F arch=b32 -S execve -F path=/usr/bin/gpasswd -F perm=x -k identity' >> /etc/audit/audit.rules
grep -q -- '-a always,exit -F arch=b64 -S execve -F path=/usr/bin/gpasswd -F perm=x -k identity' /etc/audit/audit.rules || \
    echo '-a always,exit -F arch=b64 -S execve -F path=/usr/bin/gpasswd -F perm=x -k identity' >> /etc/audit/audit.rules
