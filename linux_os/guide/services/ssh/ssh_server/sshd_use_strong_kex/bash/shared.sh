# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low
{{{ bash_instantiate_variables("sshd_strong_kex") }}}

{{{ bash_sshd_config_set(parameter="KexAlgorithms", value="$sshd_strong_kex") }}}

