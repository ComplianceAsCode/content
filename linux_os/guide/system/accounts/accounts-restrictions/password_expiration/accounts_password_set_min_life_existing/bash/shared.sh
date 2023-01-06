# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_accounts_minimum_age_login_defs") }}}

{{% call iterate_over_command_output("i", "awk -v var=\"$var_accounts_minimum_age_login_defs\" -F: '(/^[^:]+:[^!*]/ && ($4 < var || $4 == \"\")) {print $1}' /etc/shadow") -%}}
chage -m $var_accounts_minimum_age_login_defs $i
{{%- endcall %}}
