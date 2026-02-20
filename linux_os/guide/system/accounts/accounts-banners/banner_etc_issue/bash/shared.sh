# platform = multi_platform_all

login_banner_contents=$(echo "(bash-populate login_banner_contents)" | sed 's/\\n/\n/g')

{{%- if product not in ['sle15', 'slmicro5', 'slmicro6'] %}}
echo "$login_banner_contents" > /etc/issue
{{%- else %}}
{{{ bash_package_install("issue-generator") }}}
echo "$login_banner_contents" > /etc/issue.d/99-oscap-setting
{{{ bash_service_command("restart", "issue-generator") }}}
{{%- endif -%}}
