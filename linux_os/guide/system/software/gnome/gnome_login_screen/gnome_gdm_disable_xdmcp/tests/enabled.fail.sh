# platform = multi_platform_all

dnf install -y gdm

mkdir -p /etc/gdm
printf '%s\n' "# comment" "[xdmcp]" "Enable=true" > /etc/gdm/custom.conf
