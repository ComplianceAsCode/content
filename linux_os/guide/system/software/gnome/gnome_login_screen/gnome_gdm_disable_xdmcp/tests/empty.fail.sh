# platform = multi_platform_all

dnf install -y gdm

printf '%s\n' "# comment" "[xdmcp]" > /etc/gdm/custom.conf
