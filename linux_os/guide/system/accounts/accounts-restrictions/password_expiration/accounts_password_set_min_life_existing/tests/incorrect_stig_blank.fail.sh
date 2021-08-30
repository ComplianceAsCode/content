#!/bin/bash
# make existing entities pass
for acct in $(grep -ve ':\(!!\|\*\):' /etc/shadow | awk -F: '{print $1}'); do
    chage -m 1 $acct
done
# Add a failing item.
echo 'max-test-user:$1$q.YkdxU1$ADmXcU4xwPrM.Pc.dclK81:18648::60::::' >> /etc/shadow
