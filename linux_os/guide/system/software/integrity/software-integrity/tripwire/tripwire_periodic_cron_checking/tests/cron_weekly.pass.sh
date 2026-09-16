#!/bin/bash
# packages = tripwire,linux-base
# platform = multi_platform_debian

# The Debian package's default script may be relocated to a less
# frequent cron directory if daily checks are too frequent.
rm -f /etc/cron.daily/tripwire
mkdir -p /etc/cron.weekly
cat > /etc/cron.weekly/tripwire <<EOF
#!/bin/sh -e
tripwire=/usr/sbin/tripwire
[ -x \$tripwire ] || exit 0
umask 027
\$tripwire --check --quiet --email-report
EOF
chmod +x /etc/cron.weekly/tripwire
