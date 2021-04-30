# platform = multi_platform_all

{{% set target_file = "/etc/ssh/sshd_config.d/sshd_config_original.conf" -%}}
if test -f {{{ target_file}}}; then
	{{{ die("Remediation probably already happened, '" ~ target_file ~ "' already exists, not doing anything.", action="false") }}}
else
	mkdir -p /etc/ssh/sshd_config.d
	mv /etc/ssh/sshd_config {{{ target_file }}}
cat > /etc/ssh/sshd_config << EOF
# To modify the system-wide sshd configuration, create a  *.conf  file under
#  /etc/ssh/sshd_config.d/  which will be automatically included below

Include /etc/ssh/sshd_config.d/*.conf
EOF
fi
