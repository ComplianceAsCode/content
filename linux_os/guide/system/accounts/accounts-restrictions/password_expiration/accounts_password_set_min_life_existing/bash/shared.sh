# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_accounts_minimum_age_login_defs") }}}

{{% call iterate_over_command_output("i", "awk -v var=\"$var_accounts_minimum_age_login_defs\" -F: '(/^[^:]+:[^!*]/ && ($4 < var || $4 == \"\")) {print $1}' /etc/shadow") -%}}
{{% if product in ["sle12", "sle15"] %}}
passwd -q -n $var_accounts_minimum_age_login_defs $i
{{% else %}}
chage -m $var_accounts_minimum_age_login_defs $i
{{% endif %}}
{{%- endcall %}}
