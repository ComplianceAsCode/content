documentation_complete: true

title: 'VPP - Protection Profile for Virtualization v. 1.0 for Red Hat Enterprise Linux Hypervisor (RHELH)'

description: |-
    This compliance profile reflects the core set of security
    related configuration settings for deployment of Red Hat Enterprise
    Linux Hypervisor (RHELH) 7.x into U.S. Defense, Intelligence, and Civilian agencies.
    Development partners and sponsors include the U.S. National Institute
    of Standards and Technology (NIST), U.S. Department of Defense,
    the National Security Agency, and Red Hat.

    This baseline implements configuration requirements from the following
    sources:

    - Committee on National Security Systems Instruction No. 1253 (CNSSI 1253)
    - NIST 800-53 control selections for MODERATE impact systems (NIST 800-53)
    - U.S. Government Configuration Baseline (USGCB)
    - NIAP Protection Profile for Virtualization v1.0 (VPP v1.0)

    For any differing configuration requirements, e.g. password lengths, the stricter
    security setting was chosen. Security Requirement Traceability Guides (RTMs) and
    sample System Security Configuration Guides are provided via the
    scap-security-guide-docs package.

    This profile reflects U.S. Government consensus content and is developed through
    the ComplianceAsCode project, championed by the National
    Security Agency. Except for differences in formatting to accommodate
    publishing processes, this profile mirrors ComplianceAsCode
    content as minor divergences, such as bugfixes, work through the
    consensus and release processes.

selections:
    - installed_OS_is_vendor_supported

    # AC-2
    - service_auditd_enabled

    # AC-3
    - selinux_state
    - grub2_enable_selinux
    - selinux_policytype
    - grub2_password
    - grub2_uefi_password
    - grub2_disable_interactive_boot

    # AC-7(a)
    - var_accounts_passwords_pam_faillock_deny=3
    - accounts_passwords_pam_faillock_deny
    - var_accounts_passwords_pam_faillock_fail_interval=900
    - accounts_passwords_pam_faillock_interval
    - accounts_passwords_pam_faillock_deny_root

    # AC-7(b)
    - var_accounts_passwords_pam_faillock_unlock_time=never
    - accounts_passwords_pam_faillock_unlock_time

    # AC-8
    - banner_etc_issue

    # AC-17(a)
    - file_permissions_sshd_private_key
    - file_permissions_sshd_pub_key
    - disable_host_auth
    - sshd_allow_only_protocol2
    - sshd_disable_compression
    - sshd_disable_gssapi_auth
    - sshd_disable_kerb_auth
    - sshd_disable_rhosts_rsa
    - sshd_disable_root_login
    - sshd_do_not_permit_user_env
    - sshd_enable_strictmodes
    - sshd_enable_warning_banner
    - sshd_print_last_log
    - sshd_set_idle_timeout
    - sshd_set_keepalive
    - sshd_set_loglevel_info
    - sshd_use_approved_ciphers
    - sshd_use_approved_macs
    - sshd_use_priv_separation
    - sshd_disable_empty_passwords

    # AU -5(b)
    - audit_rules_system_shutdown

    # AU-9
    - file_permissions_var_log_audit
    - file_ownership_var_log_audit
    - rpm_verify_permissions
    - rpm_verify_ownership
    - rpm_verify_hashes

    # AU-12
    - grub2_audit_argument
    - audit_rules_usergroup_modification_group
    - audit_rules_usergroup_modification_gshadow
    - audit_rules_usergroup_modification_shadow
    - audit_rules_usergroup_modification_opasswd
    - audit_rules_privileged_commands
    - audit_rules_dac_modification_chown
    - audit_rules_dac_modification_fchown
    - audit_rules_dac_modification_lchown
    - audit_rules_dac_modification_fchownat
    - audit_rules_dac_modification_chmod
    - audit_rules_dac_modification_fchmod
    - audit_rules_dac_modification_fchmodat
    - audit_rules_dac_modification_setxattr
    - audit_rules_dac_modification_fsetxattr
    - audit_rules_dac_modification_lsetxattr
    - audit_rules_dac_modification_removexattr
    - audit_rules_dac_modification_fremovexattr
    - audit_rules_dac_modification_lremovexattr
    - audit_rules_unsuccessful_file_modification_creat
    - audit_rules_unsuccessful_file_modification_open
    - audit_rules_unsuccessful_file_modification_openat
    - audit_rules_unsuccessful_file_modification_open_by_handle_at
    - audit_rules_unsuccessful_file_modification_truncate
    - audit_rules_unsuccessful_file_modification_ftruncate
    - audit_rules_execution_semanage
    - audit_rules_execution_setsebool
    - audit_rules_execution_chcon
    - audit_rules_execution_setfiles
    - audit_rules_login_events_tallylog
    - audit_rules_login_events_faillock
    - audit_rules_login_events_lastlog
    - audit_rules_privileged_commands_passwd
    - audit_rules_privileged_commands_unix_chkpwd
    - audit_rules_privileged_commands_gpasswd
    - audit_rules_privileged_commands_chage
    - audit_rules_privileged_commands_userhelper
    - audit_rules_privileged_commands_su
    - audit_rules_privileged_commands_sudo
    - audit_rules_sysadmin_actions
    - audit_rules_privileged_commands_newgrp
    - audit_rules_privileged_commands_chsh
    - audit_rules_privileged_commands_sudoedit
    - audit_rules_media_export
    - audit_rules_privileged_commands_umount
    - audit_rules_privileged_commands_postdrop
    - audit_rules_privileged_commands_postqueue
    - audit_rules_privileged_commands_ssh_keysign
    - audit_rules_privileged_commands_crontab
    - audit_rules_privileged_commands_pam_timestamp_check
    - audit_rules_kernel_module_loading_init
    - audit_rules_kernel_module_loading_finit
    - audit_rules_kernel_module_loading_delete
    - audit_rules_usergroup_modification_passwd
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_renameat
    - audit_rules_file_deletion_events_rmdir
    - audit_rules_file_deletion_events_unlink
    - audit_rules_file_deletion_events_unlinkat

    # CM-11
    - ensure_gpgcheck_never_disabled
    - ensure_redhat_gpgkey_installed
    - ensure_gpgcheck_globally_activated
    - ensure_gpgcheck_local_packages
    - clean_components_post_updating

    # IA-2
    - require_singleuser_auth
    - accounts_no_uid_except_zero
    - no_direct_root_logins
    - no_password_auth_for_systemaccounts
    - restrict_serial_port_logins
    - securetty_root_login_console_only

    # IA-2 (1)
    - package_opensc_installed
    - var_smartcard_drivers=cac
    - configure_opensc_nss_db
    - configure_opensc_card_drivers
    - force_opensc_card_drivers
    - package_pcsc-lite_installed
    - service_pcscd_enabled
    - sssd_enable_smartcards

    # IA-4
    - account_disable_post_pw_expiration

    # IA-5 (1)
    - accounts_password_pam_dcredit
    - accounts_password_pam_difok
    - accounts_password_pam_maxclassrepeat
    - accounts_password_pam_maxrepeat
    - accounts_password_pam_minlen
    - accounts_password_pam_ocredit
    - accounts_password_pam_ucredit
    - accounts_password_pam_lcredit
    - accounts_maximum_age_login_defs
    - accounts_minimum_age_login_defs
    - accounts_password_pam_unix_remember
    - set_password_hashing_algorithm_logindefs
    - set_password_hashing_algorithm_systemauth
    - set_password_hashing_algorithm_libuserconf
    - no_empty_passwords

    # IA-7
    - installed_OS_is_FIPS_certified
    - grub2_enable_fips_mode

    # MP-7
    - kernel_module_usb-storage_disabled
    - kernel_module_bluetooth_disabled
    - service_bluetooth_disabled

    # SC-39
    - sysctl_kernel_exec_shield
    - sysctl_kernel_kptr_restrict
    - sysctl_kernel_randomize_va_space
    - selinux_confinement_of_daemons
    - sebool_fips_mode
