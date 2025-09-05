# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle
# reboot = true
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_selinux_policy_name") }}}

{{{ bash_selinux_config_set(parameter="SELINUXTYPE", value="$var_selinux_policy_name") }}}
