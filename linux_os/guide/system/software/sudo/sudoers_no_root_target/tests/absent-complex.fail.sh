# platform = multi_platform_all
# packages = sudo
# remediation = none

echo 'user ALL= (admin) /bin/sh, (foo bar) /baz, /bin/git' > /etc/sudoers
