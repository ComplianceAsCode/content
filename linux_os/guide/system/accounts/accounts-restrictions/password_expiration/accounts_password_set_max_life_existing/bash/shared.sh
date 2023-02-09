# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_accounts_maximum_age_login_defs") }}}

{{% if product in ["sle12", "sle15"] %}}
usrs_max_pass_age=( "$(awk -F: '$5 > $var_accounts_maximum_age_login_defs || $5 == "" {print $1}' /etc/shadow)" )
for i in "${usrs_max_pass_age[@]}"
do
  passwd -q -x $((var_accounts_maximum_age_login_defs)) $i
done
{{% else %}}
{{% call iterate_over_command_output("i", "awk -v var=\"$var_accounts_maximum_age_login_defs\" -F: '(/^[^:]+:[^!*]/ && ($5 > var || $5 == \"\")) {print $1}' /etc/shadow") -%}}
chage -M $var_accounts_maximum_age_login_defs $i
{{%- endcall %}}
{{% endif %}}
