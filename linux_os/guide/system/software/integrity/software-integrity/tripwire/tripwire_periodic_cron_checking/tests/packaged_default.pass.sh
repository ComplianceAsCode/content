#!/bin/bash
# packages = tripwire,linux-base
# platform = multi_platform_debian

# Matches the /etc/cron.daily/tripwire script shipped by the Debian
# tripwire package, written explicitly instead of relying on the
# package's post-install state so this scenario stays deterministic
# across package versions. Expected result: PASS.
mkdir -p /etc/cron.daily
cat > /etc/cron.daily/tripwire <<EOF
#!/bin/sh -e
tripwire=/usr/sbin/tripwire
[ -x \$tripwire ] || exit 0
umask 027
\$tripwire --check --quiet --email-report
EOF
chmod +x /etc/cron.daily/tripwire
