# platform = multi_platform_all
# packages = sudo
# remediation = none

echo 'user ALL= (root) /bin/sh, (foo bar) /baz, (baz bzz) /bin/git' > /etc/sudoers
