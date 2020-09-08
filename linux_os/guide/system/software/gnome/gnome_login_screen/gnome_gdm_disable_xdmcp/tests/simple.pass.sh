# platform = multi_platform_all

dnf install -y gdm

mkdir -p /etc/gdm
printf '%s\n' "# comment" "[xdmcp]" "# Enable=true" "Enable=false" > /etc/gdm/custom.conf
