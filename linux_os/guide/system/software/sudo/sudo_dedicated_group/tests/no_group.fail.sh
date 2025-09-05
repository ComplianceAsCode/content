# platform = multi_platform_all
# remediation = none
# value = var_sudo_dedicated_group=othergroup

groupadd othergroup
chown :othergroup /usr/bin/sudo
groupdel othergroup
