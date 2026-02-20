# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_sshd_remediation(parameter="GSSAPIAuthentication", value="no", config_is_distributed="false") }}}
