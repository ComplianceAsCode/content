echo "## Successful file delete" > /etc/audit/rules.d/30-ospp-v42-4-delete-success.rules
echo "-a always,exit -F arch=b32 -S unlink,unlinkat,rename,renameat -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-delete" >> /etc/audit/rules.d/30-ospp-v42-4-delete-success.rules
echo "-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-delete" >> /etc/audit/rules.d/30-ospp-v42-4-delete-success.rules
