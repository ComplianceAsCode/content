---
documentation_complete: true

metadata:
    SMEs:
        - jjaswanson4

reference: https://www.hhs.gov/hipaa/for-professionals/index.html

title: 'Health Insurance Portability and Accountability Act (HIPAA)'

description: |-
    The HIPAA Security Rule establishes U.S. national standards to protect individuals’
    electronic personal health information that is created, received, used, or
    maintained by a covered entity. The Security Rule requires appropriate
    administrative, physical and technical safeguards to ensure the
    confidentiality, integrity, and security of electronic protected health
    information.

    This profile configures Red Hat Enterprise Linux 9 to the HIPAA Security
    Rule identified for securing of electronic protected health information.
    Use of this profile in no way guarantees or makes claims against legal compliance against the HIPAA Security Rule(s).

selections:
    - hipaa:all
    - var_system_crypto_policy=fips
    - no_rsh_trust_files
    - "!audit_rules_dac_modification_fchmodat2"
    - "!audit_rules_file_deletion_events_renameat2"
    - "!audit_rules_kernel_module_loading_finit"
    - "!audit_rules_mac_modification_usr_share"
    - "!audit_rules_privileged_commands_unix2_chkpwd"
    - "!audit_rules_unsuccessful_file_modification_open_by_handle_at_o_creat"
    - "!audit_rules_unsuccessful_file_modification_open_by_handle_at_o_trunc_write"
    - "!audit_rules_unsuccessful_file_modification_open_by_handle_at_rule_order"
    - "!audit_rules_unsuccessful_file_modification_open_o_creat"
    - "!audit_rules_unsuccessful_file_modification_open_o_trunc_write"
    - "!audit_rules_unsuccessful_file_modification_open_rule_order"
    - "!audit_rules_unsuccessful_file_modification_openat_o_creat"
    - "!audit_rules_unsuccessful_file_modification_openat_o_trunc_write"
    - "!audit_rules_unsuccessful_file_modification_openat_rule_order"
    - "!audit_rules_unsuccessful_file_modification_rename"
    - "!audit_rules_unsuccessful_file_modification_renameat"
    - "!audit_rules_unsuccessful_file_modification_unlink"
    - "!audit_rules_unsuccessful_file_modification_unlinkat"
    - "!auditd_data_retention_action_mail_acct"
    - "!auditd_data_retention_admin_space_left_action"
    - "!auditd_data_retention_max_log_file_action"
    - "!auditd_data_retention_max_log_file_action_stig"
    - "!auditd_data_retention_space_left_action"
    - "!coreos_audit_option"
    - "!coreos_disable_interactive_boot"
    - "!coreos_enable_selinux_kernel_argument"
    - "!coreos_nousb_kernel_argument"
    - "!ensure_almalinux_gpgkey_installed"
    - "!ensure_fedora_gpgkey_installed"
    - "!ensure_gpgcheck_repo_metadata"
    - "!ensure_suse_gpgkey_installed"
    - "!file_groupowner_user_cfg"
    - "!file_owner_user_cfg"
    - "!file_permissions_grub2_cfg"
    - "!file_permissions_user_cfg"
    - "!grub2_admin_username"
    - "!grub2_uefi_admin_username"
    - "!grub2_uefi_password"
    - "!package_audit-audispd-plugins_installed"
    - "!package_audit_installed"
    - "!package_rsh-server_removed"
    - "!package_rsh_removed"
    - "!package_rsyslog_installed"
    - "!package_talk-server_removed"
    - "!package_talk_removed"
    - "!package_tcp_wrappers_removed"
    - "!package_xinetd_removed"
    - "!package_ypbind_removed"
    - "!package_ypserv_removed"
    - "!partition_for_var_log_audit"
    - "!require_emergency_target_auth"
    - "!service_cron_enabled"
    - "!service_rexec_disabled"
    - "!service_rlogin_disabled"
    - "!service_rsh_disabled"
    - "!service_rsyslog_enabled"
    - "!service_xinetd_disabled"
    - "!service_ypbind_disabled"
    - "!service_zebra_disabled"
    - "!sshd_disable_rhosts_rsa"
    - "!sshd_disable_user_known_hosts"
    - "!sshd_set_keepalive"
    - "!sshd_set_keepalive_0"
    - "!sshd_use_approved_ciphers"
    - "!sshd_use_approved_macs"
    - "!sshd_use_priv_separation"
