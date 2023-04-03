#!/bin/bash
#
# packages = aide

# This TS is a regression test for https://bugzilla.redhat.com/show_bug.cgi?id=2175684

mkdir -p /etc/cron.daily
cat > /etc/cron.daily/aide << EOF
#!/bin/sh
nice ionice /usr/sbin/aide --check
nice ionice /usr/sbin/aide --init
/bin/mv -f /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
EOF
