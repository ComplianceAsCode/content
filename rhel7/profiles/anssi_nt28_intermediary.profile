documentation_complete: false

title: 'ANSSI DAT-NT28 (intermediary)'

description: 'Draft profile for ANSSI compliance at the intermediary level. ANSSI stands for Agence nationale de la sécurité
    des systèmes d''information. Based on https://www.ssi.gouv.fr/.'

extends: anssi_nt28_minimal

selections:
    - partition_for_tmp
    - partition_for_var
    - partition_for_var_log
    - partition_for_var_log_audit
    - partition_for_home
    - sshd_idle_timeout_value=5_minutes
    - rsyslog_files_ownership
    - rsyslog_files_groupownership
    - rsyslog_files_permissions
    - "!rsyslog_remote_loghost"
    - ensure_logrotate_activated
    - sysctl_fs_suid_dumpable
    - sysctl_kernel_randomize_va_space
