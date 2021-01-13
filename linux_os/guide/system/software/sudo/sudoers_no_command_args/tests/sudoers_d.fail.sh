# platform = multi_platform_all
# packages = sudo
# remediation = none

echo 'nobody ALL=/bin/ls, (!bob,alice) /bin/dog arg, /bin/cat ""' > /etc/sudoers
echo 'jen,!fred		ALL,!SERVERS = /bin/sh arg' >> /etc/sudoers
echo 'nobody ALL=/bin/ls, (bob,!alice) /bin/dog arg, /bin/cat arg' > /etc/sudoers.d/foo

echo 'user ALL = ALL' > /etc/sudoers.d/bar
