documentation_complete: true

metadata:
    SMEs:
        - abergmann

reference: https://www.hhs.gov/hipaa/for-professionals/index.html

title: 'Health Insurance Portability and Accountability Act (HIPAA)'

description: |-
    The HIPAA Security Rule establishes U.S. national standards to protect individuals'
    electronic personal health information that is created, received, used, or
    maintained by a covered entity. The Security Rule requires appropriate
    administrative, physical and technical safeguards to ensure the
    confidentiality, integrity, and security of electronic protected health
    information.

    This profile contains configuration checks that align to the
    HIPPA Security Rule for SUSE Linux Micro 6.2.

selections:
    - hipaa:all
    - grub2_nousb_argument
    - '!dconf_db_up_to_date'
    - '!dconf_gnome_remote_access_credential_prompt'
    - '!dconf_gnome_remote_access_encryption'
    - '!package_sequoia-sq_installed'
    - '!ensure_almalinux_gpgkey_installed'
    - '!ensure_fedora_gpgkey_installed'
    - '!ensure_redhat_gpgkey_installed'
    - '!enable_authselect'
    - '!coreos_disable_interactive_boot'
    - '!file_groupowner_user_cfg'
    - '!file_owner_user_cfg'
    - '!file_permissions_user_cfg'
    - '!package_rsyslog_installed'
    - '!service_rsyslog_enabled'
    - '!rsyslog_remote_loghost'
    - '!libreswan_approved_tunnels'
    - '!service_autofs_disabled'
    - '!coreos_nousb_kernel_argument'
    - '!coreos_enable_selinux_kernel_argument'
    - '!package_cron_installed'
    - '!service_cron_enabled'
    - '!service_crond_enabled'
    - '!package_postfix_installed'
    - '!package_tcp_wrappers_removed'
    - '!package_xinetd_removed'
    - '!service_xinetd_disabled'
    - '!package_ypbind_removed'
    - '!package_ypserv_removed'
    - '!service_ypbind_disabled'
    - '!package_rsh-server_removed'
    - '!package_rsh_removed'
    - '!service_rexec_disabled'
    - '!service_rlogin_disabled'
    - '!service_rsh_disabled'
    - '!package_talk-server_removed'
    - '!package_talk_removed'
    - '!package_telnet-server_removed'
    - '!package_telnet_removed'
    - '!service_telnet_disabled'
    - '!service_zebra_disabled'
    - '!coreos_audit_option'
    - var_accounts_passwords_pam_faillock_dir=run
    - '!audit_rules_login_events_tallylog'
    - '!audit_rules_privileged_commands_crontab'
    - '!audit_rules_privileged_commands_postdrop'
    - '!audit_rules_privileged_commands_postqueue'
    - '!audit_rules_privileged_commands_unix2_chkpwd'
    - '!audit_rules_privileged_commands_userhelper'
    - '!auditd_data_retention_max_log_file_action_stig'
