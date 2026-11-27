# platform = multi_platform_all

{{% if 'suse' in families and product != 'sle12' %}}
    {{{ set_config_file(path=sshd_main_config_file, parameter='Include', value=sshd_config_dir ~ "/*.conf", rule_id=rule_id) }}}
{{% else %}}
{{% set base_config = sshd_main_config_file -%}}
{{% set config_dir = sshd_config_dir -%}}
{{% set target_file = config_dir ~ "/sshd_config_original.conf" -%}}
{{% set include_directive = "Include " ~ config_dir ~ "/*.conf" -%}}
{{% set include_regex = "^\\s*Include\\s+" ~ (config_dir | replace(".", "\\.")) ~ "/\\*\\.conf" -%}}
{{# Include directive with config_dir/*.conf or config_dir/* among its arguments, keyword in any case and path
   absolute or relative to sshd_config_base_dir. In target_file, it would make target_file include itself. -#}}
{{% set config_dir_regex = "(" ~ (sshd_config_base_dir | replace(".", "\\.")) ~ "/)?" ~ (config_dir | replace(sshd_config_base_dir ~ "/", "", 1) | replace(".", "\\.")) -%}}
{{% set self_include_regex = "^[[:space:]]*[Ii][Nn][Cc][Ll][Uu][Dd][Ee]([[:space:]]*=[[:space:]]*|[[:space:]]+)([^#[:space:]][^[:space:]]*[[:space:]]+)*\"?" ~ config_dir_regex ~ "/\\*(\\.conf)?\"?([[:space:]]|$)" -%}}
if test -f {{{ target_file }}}; then
	if grep -Eq '{{{ self_include_regex }}}' {{{ target_file }}}; then
		# Previous versions of this remediation kept the Include directive in the moved file
		sed -E -i '\%{{{ self_include_regex }}}%s/^/# /' {{{ target_file }}}
	else
		{{{ die("Remediation probably already happened, '" ~ target_file ~ "' already exists, not doing anything.", action="false") }}}
	fi
elif grep -Eq '{{{ include_regex }}}' {{{ base_config }}} && ! grep -Eq '^\s*Match\s' {{{ base_config }}}; then
	{{{ die("Remediation probably already happened, '" ~ base_config ~ "' already contains the include directive.", action="false") }}}
else
	mkdir -p {{{ config_dir }}}
	chmod 0700 {{{ config_dir }}}
	mv {{{ base_config }}} {{{ target_file }}}
	# The new main configuration file includes the moved file, which therefore must not include its own directory,
	# otherwise sshd fails with "Too many recursive configuration includes"
	sed -E -i '\%{{{ self_include_regex }}}%s/^/# /' {{{ target_file }}}
cat > {{{ base_config }}} << EOF
# To modify the system-wide sshd configuration, create a  *.conf  file under
#  {{{ config_dir }}}/  which will be automatically included below

{{{ include_directive }}}
EOF
chmod 0600 {{{ base_config }}}
fi
{{% endif %}}
