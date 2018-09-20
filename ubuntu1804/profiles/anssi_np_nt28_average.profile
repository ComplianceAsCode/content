documentation_complete: true

title: 'Profile for ANSSI DAT-NT28 Average (Intermediate) Level'

description: 'This profile contains items for GNU/Linux installations already protected by multiple higher level security
    stacks.'

extends: anssi_np_nt28_minimal

selections:
    - partition_for_tmp
    - partition_for_var
    - partition_for_var_log
    - partition_for_var_log_audit
    - partition_for_home
    - package_ntp_installed
    - package_ntpdate_removed
    - sshd_idle_timeout_value=5_minutes
    - sshd_set_idle_timeout
    - sshd_disable_root_login
    - sshd_disable_empty_passwords
    - sshd_allow_only_protocol2
    - sshd_set_keepalive
    - file_owner_logfiles_value=adm
    - rsyslog_files_ownership
    - file_groupowner_logfiles_value=adm
    - rsyslog_files_groupownership
    - rsyslog_files_permissions
    - "!rsyslog_remote_loghost"
    - ensure_logrotate_activated
    - file_permissions_systemmap
    - sysctl_fs_protected_symlinks
    - sysctl_fs_protected_hardlinks
    - sysctl_fs_suid_dumpable
    - sysctl_kernel_randomize_va_space
