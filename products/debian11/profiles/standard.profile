documentation_complete: true

title: 'Standard System Security Profile for Debian 11'

description: |-
    This profile contains rules to ensure standard security baseline
    of a Debian 11 system. Regardless of your system's workload
    all of these checks should pass.

selections:
    - partition_for_tmp
    - partition_for_var
    - partition_for_var_log
    - partition_for_var_log_audit
    - partition_for_home
    - package_audit_installed
    - package_cron_installed
    - package_ntp_installed
    - package_rsyslog_installed
    - package_telnetd_removed
    - package_inetutils-telnetd_removed
    - package_telnetd-ssl_removed
    - package_nis_removed
    - package_ntpdate_removed
    - service_auditd_enabled
    - service_cron_enabled
    - service_ntp_enabled
    - service_rsyslog_enabled
    - sshd_idle_timeout_value=5_minutes
    - sshd_set_idle_timeout
    - sshd_disable_root_login
    - sshd_disable_empty_passwords
    - sshd_allow_only_protocol2
    - var_sshd_set_keepalive=0
    - sshd_set_keepalive_0
    - file_owner_logfiles_value=adm
    - rsyslog_files_ownership
    - file_groupowner_logfiles_value=adm
    - rsyslog_files_groupownership
    - rsyslog_files_permissions
    - "!rsyslog_remote_loghost"
    - ensure_logrotate_activated
    - file_permissions_systemmap
    - file_permissions_etc_shadow
    - file_owner_etc_shadow
    - file_groupowner_etc_shadow
    - file_permissions_etc_gshadow
    - file_owner_etc_gshadow
    - file_groupowner_etc_gshadow
    - file_permissions_etc_passwd
    - file_owner_etc_passwd
    - file_groupowner_etc_passwd
    - file_permissions_etc_group
    - file_owner_etc_group
    - file_groupowner_etc_group
    - sysctl_fs_protected_symlinks
    - sysctl_fs_protected_hardlinks
    - sysctl_fs_suid_dumpable
    - sysctl_kernel_randomize_va_space
