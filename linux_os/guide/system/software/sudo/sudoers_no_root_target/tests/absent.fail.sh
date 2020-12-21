# platform = multi_platform_all
# packages = sudo
# remediation = none

# No spec of users that user can impersonate
echo 'user ALL= ALL' > /etc/sudoers

