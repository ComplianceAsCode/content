#!/bin/bash
# packages = tripwire,linux-base

# Matches the /etc/cron.daily/tripwire script shipped by the Debian
# tripwire package. Other distributions ship an equivalent script under
# a different filename (e.g. Fedora's /etc/cron.daily/tripwire-check),
# which the check also matches since it doesn't depend on the filename.
# Written explicitly here instead of relying on the packaged file so
# this scenario stays deterministic across package versions and
# distributions. Expected result: PASS.
mkdir -p /etc/cron.daily
cat > /etc/cron.daily/tripwire <<EOF
#!/bin/sh -e
tripwire=/usr/sbin/tripwire
[ -x \$tripwire ] || exit 0
umask 027
\$tripwire --check --quiet --email-report
EOF
chmod +x /etc/cron.daily/tripwire
