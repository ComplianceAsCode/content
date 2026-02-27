# platform = multi_platform_all

{{% set base_config = sshd_main_config_file -%}}
{{% set config_dir = sshd_config_dir -%}}
{{% set target_file = config_dir ~ "/sshd_config_original.conf" -%}}
{{% set include_directive = "Include " ~ config_dir ~ "/*.conf" -%}}
{{% set include_regex = "^\\s*Include\\s+" ~ (config_dir | replace(".", "\\.")) ~ "/\\*\\.conf" -%}}
if test -f {{{ target_file}}}; then
	{{{ die("Remediation probably already happened, '" ~ target_file ~ "' already exists, not doing anything.", action="false") }}}
elif grep -Eq '{{{ include_regex }}}' {{{ base_config }}} && ! grep -Eq '^\s*Match\s' {{{ base_config }}}; then
	{{{ die("Remediation probably already happened, '" ~ base_config ~ "' already contains the include directive.", action="false") }}}
else
	mkdir -p {{{ config_dir }}}
	mv {{{ base_config }}} {{{ target_file }}}
cat > {{{ base_config }}} << EOF
# To modify the system-wide sshd configuration, create a  *.conf  file under
#  {{{ config_dir }}}/  which will be automatically included below

{{{ include_directive }}}
EOF
fi
