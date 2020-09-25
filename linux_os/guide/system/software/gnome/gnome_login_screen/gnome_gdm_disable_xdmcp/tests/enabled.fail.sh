# packages = gdm

mkdir -p /etc/gdm
printf '%s\n' "# comment" "[xdmcp]" "Enable=true" > /etc/gdm/custom.conf
