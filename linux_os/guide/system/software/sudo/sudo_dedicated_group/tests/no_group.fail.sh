# platform = multi_platform_all
# value = var_sudo_dedicated_group=othergroup

groupadd othergroup
chown :othergroup /usr/bin/sudo
groupdel othergroup
