documentation_complete: true

metadata:
    version: 5.4
    SMEs:
        - ggbecker

reference: https://www.fbi.gov/services/cjis/cjis-security-policy-resource-center

title: 'Criminal Justice Information Services (CJIS) Security Policy'

description: |-
    This profile is derived from FBI's CJIS v5.4
    Security Policy. A copy of this policy can be found at the CJIS Security
    Policy Resource Center:

    https://www.fbi.gov/services/cjis/cjis-security-policy-resource-center

selections:
    - service_auditd_enabled
    - grub2_audit_argument
    - auditd_data_retention_num_logs
    - auditd_data_retention_max_log_file
    - auditd_data_retention_max_log_file_action
    - auditd_data_retention_space_left_action
    - auditd_data_retention_admin_space_left_action
    - auditd_data_retention_action_mail_acct
    - auditd_audispd_syslog_plugin_activated
    - audit_rules_time_adjtimex
    - audit_rules_time_settimeofday
    - audit_rules_time_stime
    - audit_rules_time_clock_settime
    - audit_rules_time_watch_localtime
    - audit_rules_usergroup_modification
    - audit_rules_networkconfig_modification
    - file_permissions_var_log_audit
    - file_ownership_var_log_audit
    - audit_rules_mac_modification
    - audit_rules_dac_modification_chmod
    - audit_rules_dac_modification_chown
    - audit_rules_dac_modification_fchmod
    - audit_rules_dac_modification_fchmodat
    - audit_rules_dac_modification_fchown
    - audit_rules_dac_modification_fchownat
    - audit_rules_dac_modification_fremovexattr
    - audit_rules_dac_modification_fsetxattr
    - audit_rules_dac_modification_lchown
    - audit_rules_dac_modification_lremovexattr
    - audit_rules_dac_modification_lsetxattr
    - audit_rules_dac_modification_removexattr
    - audit_rules_dac_modification_setxattr
    - audit_rules_login_events
    - audit_rules_session_events
    - audit_rules_unsuccessful_file_modification
    - audit_rules_privileged_commands
    - audit_rules_media_export
    - audit_rules_file_deletion_events
    - audit_rules_sysadmin_actions
    - audit_rules_kernel_module_loading
    - audit_rules_immutable
    - account_unique_name
    - gid_passwd_group_same
    - accounts_password_all_shadowed
    - no_empty_passwords
    - display_login_attempts
    - var_accounts_maximum_age_login_defs=90
    - var_password_pam_unix_remember=10
    - var_account_disable_post_pw_expiration=0
    - var_password_pam_minlen=12
    - var_accounts_minimum_age_login_defs=1
    - var_password_pam_difok=6
    - var_accounts_max_concurrent_login_sessions=3
    - account_disable_post_pw_expiration
    - accounts_password_pam_minlen
    - accounts_minimum_age_login_defs
    - accounts_password_pam_difok
    - var_authselect_profile=sssd
    - enable_authselect
    - accounts_max_concurrent_login_sessions
    - set_password_hashing_algorithm_systemauth
    - set_password_hashing_algorithm_passwordauth
    - set_password_hashing_algorithm_logindefs
    - set_password_hashing_algorithm_libuserconf
    - file_owner_etc_shadow
    - file_groupowner_etc_shadow
    - file_permissions_etc_shadow
    - file_owner_etc_group
    - file_groupowner_etc_group
    - file_permissions_etc_group
    - file_owner_etc_passwd
    - file_groupowner_etc_passwd
    - file_permissions_etc_passwd
    - file_owner_grub2_cfg
    - file_groupowner_grub2_cfg
    - var_password_pam_retry=5
    - var_accounts_passwords_pam_faillock_deny=5
    - var_accounts_passwords_pam_faillock_unlock_time=600
    - dconf_db_up_to_date
    - dconf_gnome_screensaver_idle_delay
    - dconf_gnome_session_idle_user_locks
    - dconf_gnome_screensaver_idle_activation_enabled
    - dconf_gnome_screensaver_lock_enabled
    - dconf_gnome_screensaver_mode_blank
    - sshd_allow_only_protocol2
    - sshd_set_idle_timeout
    - var_sshd_set_keepalive=0
    - logind_session_timeout
    - sshd_set_keepalive_0
    - disable_host_auth
    - sshd_disable_root_login
    - sshd_disable_empty_passwords
    - sshd_enable_warning_banner
    - sshd_do_not_permit_user_env
    - var_system_crypto_policy=fips
    - configure_crypto_policy
    - configure_ssh_crypto_policy
    - kernel_module_dccp_disabled
    - kernel_module_sctp_disabled
    - service_firewalld_enabled
    - set_firewalld_default_zone
    - firewalld_sshd_port_enabled
    - sshd_idle_timeout_value=30_minutes
    - var_logind_session_timeout=30_minutes
    - inactivity_timeout_value=30_minutes
    - sysctl_net_ipv4_conf_default_accept_source_route
    - sysctl_net_ipv4_tcp_syncookies
    - sysctl_net_ipv4_conf_all_send_redirects
    - sysctl_net_ipv4_conf_default_send_redirects
    - sysctl_net_ipv4_conf_all_accept_redirects
    - sysctl_net_ipv4_conf_default_accept_redirects
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts
    - var_password_pam_ocredit=1
    - var_password_pam_dcredit=1
    - var_password_pam_ucredit=1
    - var_password_pam_lcredit=1
    - package_aide_installed
    - aide_build_database
    - aide_periodic_cron_checking
    - rpm_verify_permissions
    - rpm_verify_hashes
    - ensure_redhat_gpgkey_installed
    - ensure_gpgcheck_globally_activated
    - ensure_gpgcheck_never_disabled
    - security_patches_up_to_date
    - kernel_module_bluetooth_disabled
