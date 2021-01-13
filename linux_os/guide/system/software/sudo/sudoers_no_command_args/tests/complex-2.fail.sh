# platform = multi_platform_all
# packages = sudo
# remediation = none

echo 'nobody ALL=/bin/ls, (!bob,alice) /bin/dog, /bin/cat arg' > /etc/sudoers
