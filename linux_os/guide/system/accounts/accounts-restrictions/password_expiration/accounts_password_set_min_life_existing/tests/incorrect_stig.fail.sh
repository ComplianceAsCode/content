#!/bin/bash
# make existing entries pass
# assumption: use a nominally large value for var_accounts_minimum_age_login_defs
#             so as to not interfere.
for acct in $(grep -ve ':\(!!\|\*\):' /etc/shadow | awk -F: '{print $1}'); do
    chage -m 300 -d $(date +%Y-%m-%d) $acct
done
# add a failing entry
echo 'max-test-user:$1$q.YkdxU1$ADmXcU4xwPrM.Pc.dclK81:18648:0:60::::' >> /etc/shadow
echo "max-test-user:x:50000:1000::/:/usr/bin/bash" >> /etc/passwd
