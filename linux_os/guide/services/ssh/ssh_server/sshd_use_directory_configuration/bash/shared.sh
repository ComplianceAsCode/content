# platform = multi_platform_all

{{% set target_file = "/etc/ssh/sshd_config.d/sshd_config_original.conf" -%}}
{{% set base_config = "/etc/ssh/sshd_config" -%}}
if test -f {{{ target_file}}}; then
	{{{ die("Remediation probably already happened, '" ~ target_file ~ "' already exists, not doing anything.", action="false") }}}
elif grep -Eq '^\s*Include\s+/etc/ssh/sshd_config\.d/\*\.conf' {{{ base_config }}} && ! grep -Eq '^\s*Match\s' {{{ base_config }}}; then
	{{{ die("Remediation probably already happened, '" ~ base_config ~ "' already contains the include directive.", action="false") }}}
else
	mkdir -p /etc/ssh/sshd_config.d
	mv {{{ base_config }}} {{{ target_file }}}
cat > {{{ base_config }}} << EOF
# To modify the system-wide sshd configuration, create a  *.conf  file under
#  /etc/ssh/sshd_config.d/  which will be automatically included below

Include /etc/ssh/sshd_config.d/*.conf
EOF
fi
