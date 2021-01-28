# platform = multi_platform_all
# packages = sudo

echo 'nobody ALL=/bin/ls "", (!bob,alice) /bin/dog arg, /bin/cat ""' > /etc/sudoers
echo 'jen,!fred		ALL,!SERVERS = /bin/sh arg' >> /etc/sudoers
echo 'nobody ALL=/bin/ls arg arg, (bob,!alice) /bin/dog arg, /bin/cat arg' > /etc/sudoers.d/foo
