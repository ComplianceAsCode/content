#!/bin/bash
# packages = aide,crontabs

# This TS is a regression test for https://bugzilla.redhat.com/show_bug.cgi?id=2175684

mkdir -p /etc/cron.daily
cat > /etc/cron.daily/aide << EOF
#!/bin/sh
nice ionice {{{ aide_bin_path }}} --check
nice ionice {{{ aide_bin_path }}} --init
/bin/mv -f /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
EOF
