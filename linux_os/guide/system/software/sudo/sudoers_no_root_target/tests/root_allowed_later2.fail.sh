# platform = multi_platform_all
# packages = sudo
# remediation = none

echo 'user ALL= (admin) /bin/sh, (foo bar) /baz, (baz bzz) /bin/git, (nobody ALL somebody)  /bin/touch' > /etc/sudoers
