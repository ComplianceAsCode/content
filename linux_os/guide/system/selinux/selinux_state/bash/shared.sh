# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platorm_ol,multi_platform_rhv
# reboot = true
# strategy = restrict
# complexity = low
# disruption = low

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

{{{ bash_instantiate_variables("var_selinux_state") }}}

{{{ bash_selinux_config_set(parameter="SELINUX", value="$var_selinux_state") }}}

fixfiles onboot
fixfiles -f relabel
