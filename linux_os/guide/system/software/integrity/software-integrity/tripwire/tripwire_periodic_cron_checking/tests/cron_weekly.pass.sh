#!/bin/bash
# packages = tripwire,linux-base

# The default cron.daily script (whether packaged, as on Debian, or
# written by hand, as required on distributions that don't ship one,
# e.g. Fedora) may be relocated to a less frequent cron directory if
# daily checks are too frequent. Expected result: PASS.
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
