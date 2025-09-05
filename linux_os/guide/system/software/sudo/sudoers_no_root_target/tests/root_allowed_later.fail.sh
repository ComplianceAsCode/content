# platform = multi_platform_all
# packages = sudo
# remediation = none

echo 'user ALL= (admin) /bin/sh, (foo bar) /baz, (baz root bzz) /bin/git' > /etc/sudoers
