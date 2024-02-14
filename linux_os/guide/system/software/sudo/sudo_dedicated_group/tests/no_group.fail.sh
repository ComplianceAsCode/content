# platform = multi_platform_all
# remediation = none
# variables = var_sudo_dedicated_group=othergroup

groupadd othergroup
chown :othergroup /usr/bin/sudo
groupdel othergroup
