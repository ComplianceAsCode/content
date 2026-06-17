documentation_complete: true

metadata:
    SMEs:
        - abergmann

reference: https://www.hhs.gov/hipaa/for-professionals/index.html

title: 'Health Insurance Portability and Accountability Act (HIPAA)'

description: |-
    The HIPAA Security Rule establishes U.S. national standards to protect individuals’
    electronic personal health information that is created, received, used, or
    maintained by a covered entity. The Security Rule requires appropriate
    administrative, physical and technical safeguards to ensure the
    confidentiality, integrity, and security of electronic protected health
    information.

    This profile contains configuration checks that align to the
    HIPPA Security Rule for SUSE Linux Enterprise 15 V1R3.

selections:
    - hipaa:all
    - '!audit_rules_immutable'
    - audit_rules_session_events
    - audit_sudo_log_events
    - enable_dconf_user_profile
    - no_rsh_trust_files
    - '!audit_rules_dac_modification_fchmodat2'
    - audit_rules_file_deletion_events_renameat2
    - audit_rules_kernel_module_loading_finit
    - audit_rules_mac_modification_usr_share
    - audit_rules_privileged_commands_unix2_chkpwd
    - audit_rules_session_events_btmp
    - audit_rules_session_events_utmp
    - audit_rules_session_events_wtmp
    - '!audit_rules_unsuccessful_file_modification_open_by_handle_at_o_creat'
    - '!audit_rules_unsuccessful_file_modification_open_by_handle_at_o_trunc_write'
    - '!audit_rules_unsuccessful_file_modification_open_by_handle_at_rule_order'
    - '!audit_rules_unsuccessful_file_modification_open_o_creat'
    - '!audit_rules_unsuccessful_file_modification_open_o_trunc_write'
    - '!audit_rules_unsuccessful_file_modification_open_rule_order'
    - '!audit_rules_unsuccessful_file_modification_openat_o_creat'
    - '!audit_rules_unsuccessful_file_modification_openat_o_trunc_write'
    - '!audit_rules_unsuccessful_file_modification_openat_rule_order'
    - audit_rules_unsuccessful_file_modification_rename
    - audit_rules_unsuccessful_file_modification_renameat
    - audit_rules_unsuccessful_file_modification_unlink
    - audit_rules_unsuccessful_file_modification_unlinkat
    - auditd_data_retention_action_mail_acct
    - auditd_data_retention_admin_space_left_action
    - auditd_data_retention_max_log_file_action
    - auditd_data_retention_max_log_file_action_stig
    - auditd_data_retention_space_left_action
    - '!coreos_audit_option'
    - '!coreos_disable_interactive_boot'
    - '!coreos_enable_selinux_kernel_argument'
    - '!coreos_nousb_kernel_argument'
    - '!enable_authselect'
    - '!ensure_almalinux_gpgkey_installed'
    - '!ensure_fedora_gpgkey_installed'
    - '!ensure_gpgcheck_repo_metadata'
    - '!ensure_redhat_gpgkey_installed'
    - '!file_groupowner_user_cfg'
    - '!file_owner_user_cfg'
    - '!file_permissions_user_cfg'
    - '!grub2_admin_username'
    - grub2_audit_backlog_limit_argument
    - '!grub2_uefi_admin_username'
    - '!package_postfix_installed'
    - package_rsh_removed
    - package_rsyslog_installed
    - '!package_sequoia-sq_installed'
    - package_tcp_wrappers_removed
    - package_ypbind_removed
    - package_ypserv_removed
    - partition_for_var_log_audit
    - require_emergency_target_auth
    - '!service_crond_enabled'
    - '!service_rsh_disabled'
    - service_rsyslog_enabled
    - '!service_ypbind_disabled'
    - sshd_disable_compression
    - '!sshd_disable_rhosts_rsa'
    - sshd_disable_user_known_hosts
    - sshd_set_keepalive
    - sshd_use_approved_ciphers
    - sshd_use_approved_macs
    - '!sshd_use_directory_configuration'
    - sshd_use_priv_separation
