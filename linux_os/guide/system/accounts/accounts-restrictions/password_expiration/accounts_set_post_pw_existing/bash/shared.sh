# platform = multi_platform_sle
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_account_disable_post_pw_expiration") }}}

{{% call iterate_over_command_output("i", "awk -v var=\"$var_account_disable_post_pw_expiration\" -F: '$7 > var || $7 == \"\" {print $1}' /etc/shadow") -%}}
chage --inactive $var_account_disable_post_pw_expiration $i
{{%- endcall %}}
