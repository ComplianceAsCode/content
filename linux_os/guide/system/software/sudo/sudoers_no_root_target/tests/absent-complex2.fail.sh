# platform = multi_platform_all
# packages = sudo
# remediation = none

echo 'user ALL= (admin) /bin/sh, /baz, (foo bar) /bin/git' > /etc/sudoers
