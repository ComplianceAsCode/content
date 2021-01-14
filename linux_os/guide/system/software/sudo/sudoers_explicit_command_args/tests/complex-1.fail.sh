# platform = multi_platform_all
# packages = sudo
# remediation = none

echo 'somebody ALL=/bin/ls, (!bob,alice) /bin/cat arg, /bin/dog' > /etc/sudoers
