documentation_complete: true

metadata:
    SMEs:
        - carlosmmatos

title: 'NIST National Checklist for Red Hat Enterprise Linux CoreOS'

description: |-
    This compliance profile reflects the core set of security
    related configuration settings for deployment of Red Hat Enterprise
    Linux CoreOS into U.S. Defense, Intelligence, and Civilian agencies.
    Development partners and sponsors include the U.S. National Institute
    of Standards and Technology (NIST), U.S. Department of Defense,
    the National Security Agency, and Red Hat.

    This baseline implements configuration requirements from the following
    sources:

    - Committee on National Security Systems Instruction No. 1253 (CNSSI 1253)
    - NIST Controlled Unclassified Information (NIST 800-171)
    - NIST 800-53 control selections for Moderate-Impact systems (NIST 800-53)
    - U.S. Government Configuration Baseline (USGCB)
    - NIAP Protection Profile for General Purpose Operating Systems v4.2.1 (OSPP v4.2.1)
    - DISA Operating System Security Requirements Guide (OS SRG)

    For any differing configuration requirements, e.g. password lengths, the stricter
    security setting was chosen. Security Requirement Traceability Guides (RTMs) and
    sample System Security Configuration Guides are provided via the
    scap-security-guide-docs package.

    This profile reflects U.S. Government consensus content and is developed through
    the ComplianceAsCode initiative, championed by the National
    Security Agency. Except for differences in formatting to accommodate
    publishing processes, this profile mirrors ComplianceAsCode
    content as minor divergences, such as bugfixes, work through the
    consensus and release processes.

selections:
    #######################################################
    ### GENERAL REQUIREMENTS
    ### Things needed to meet OSPP functional requirements.
    #######################################################

    ### Partitioning
    #- mount_option_home_nodev
    #- mount_option_home_nosuid
    #- mount_option_tmp_nodev
    #- mount_option_tmp_noexec
    #- mount_option_tmp_nosuid
    #- mount_option_var_tmp_nodev
    #- mount_option_var_tmp_noexec
    #- mount_option_var_tmp_nosuid
    #- mount_option_dev_shm_nodev
    #- mount_option_dev_shm_noexec
    #- mount_option_dev_shm_nosuid
    #- mount_option_nodev_nonroot_local_partitions
    #- mount_option_boot_nodev
    #- mount_option_boot_nosuid
    #- partition_for_home
    #- partition_for_var
    #- mount_option_var_nodev
    #- partition_for_var_log
    #- mount_option_var_log_nodev
    #- mount_option_var_log_nosuid
    #- mount_option_var_log_noexec
    #- partition_for_var_log_audit
    #- mount_option_var_log_audit_nodev
    #- mount_option_var_log_audit_nosuid
    #- mount_option_var_log_audit_noexec

    ### Services
    # sshd
    #- sshd_disable_root_login
    #- sshd_enable_strictmodes
    #- disable_host_auth
    #- sshd_disable_empty_passwords
    #- sshd_disable_kerb_auth
    #- sshd_disable_gssapi_auth
    #- sshd_set_keepalive
    #- sshd_enable_warning_banner
    #- sshd_rekey_limit
    

    # Time Server
    - chronyd_client_only
    - chronyd_no_chronyc_network

    ### Network Settings
    - sysctl_net_ipv6_conf_all_accept_ra
    - sysctl_net_ipv6_conf_default_accept_ra
    - sysctl_net_ipv4_conf_all_accept_redirects
    - sysctl_net_ipv4_conf_default_accept_redirects
    - sysctl_net_ipv6_conf_all_accept_redirects
    - sysctl_net_ipv6_conf_default_accept_redirects
    - sysctl_net_ipv4_conf_all_accept_source_route
    - sysctl_net_ipv4_conf_default_accept_source_route
    - sysctl_net_ipv6_conf_all_accept_source_route
    - sysctl_net_ipv6_conf_default_accept_source_route
    - sysctl_net_ipv4_conf_all_secure_redirects
    - sysctl_net_ipv4_conf_default_secure_redirects
    - sysctl_net_ipv4_conf_all_send_redirects
    - sysctl_net_ipv4_conf_default_send_redirects
    - sysctl_net_ipv4_conf_all_log_martians
    - sysctl_net_ipv4_conf_default_log_martians
    - sysctl_net_ipv4_conf_all_rp_filter
    - sysctl_net_ipv4_conf_default_rp_filter
    - sysctl_net_ipv4_icmp_ignore_bogus_error_responses
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts
    - sysctl_net_ipv4_tcp_syncookies

    ### systemd
    - disable_ctrlaltdel_reboot
    - disable_ctrlaltdel_burstaction
    - service_debug-shell_disabled

    ### umask
    #- var_accounts_user_umask=027
    #- accounts_umask_etc_profile
    #- accounts_umask_etc_bashrc
    #- accounts_umask_etc_csh_cshrc

    ### Software update
    #- ensure_redhat_gpgkey_installed
    #- ensure_gpgcheck_globally_activated
    #- ensure_gpgcheck_local_packages
    #- ensure_gpgcheck_never_disabled

    ### Passwords
    #- var_password_pam_difok=4
    #- accounts_password_pam_difok
    #- var_password_pam_maxrepeat=3
    #- accounts_password_pam_maxrepeat
    #- var_password_pam_maxclassrepeat=4
    #- accounts_password_pam_maxclassrepeat

    ### Kernel Config
    ## Boot prompt
    - coreos_audit_option
    - coreos_audit_backlog_limit_kernel_argument
    - coreos_slub_debug_kernel_argument
    - coreos_page_poison_kernel_argument
    - coreos_vsyscall_kernel_argument
    - coreos_vsyscall_kernel_argument.role=unscored
    - coreos_vsyscall_kernel_argument.severity=info
    - coreos_pti_kernel_argument

    ## Security Settings
    - sysctl_kernel_kptr_restrict
    - sysctl_kernel_dmesg_restrict
    - sysctl_kernel_kexec_load_disabled
    - sysctl_kernel_yama_ptrace_scope
    - sysctl_kernel_perf_event_paranoid
    - sysctl_kernel_unprivileged_bpf_disabled
    - sysctl_net_core_bpf_jit_harden

    ## File System Settings
    - sysctl_fs_protected_hardlinks
    - sysctl_fs_protected_symlinks

    ### Audit
    - service_auditd_enabled
    - var_auditd_flush=incremental_async
    - auditd_data_retention_flush
    - auditd_local_events
    - auditd_write_logs
    - auditd_log_format
    - auditd_freq
    - auditd_name_format
    - var_auditd_action_mail_acct=root
    - var_auditd_space_left_action=email
    
    #####
    # Need to replace with fluentd checks
    #- auditd_audispd_configure_remote_server
    #- auditd_audispd_encrypt_sent_records
    #- auditd_audispd_disk_full_action
    #- auditd_audispd_network_failure_action
    #####

    ### Module Blacklist
    - kernel_module_cramfs_disabled
    - kernel_module_bluetooth_disabled
    - kernel_module_sctp_disabled
    - kernel_module_firewire-core_disabled
    - kernel_module_atm_disabled
    - kernel_module_can_disabled
    - kernel_module_tipc_disabled

    ### rpcbind

    ### Install Required Packages
    #- package_sssd-ipa_installed
    - package_aide_installed
    - package_iptables_installed
    #- package_libcap-ng-utils_installed
    #- package_openscap-scanner_installed
    #- package_policycoreutils_installed
    - package_sudo_installed
    - package_usbguard_installed
    ####
    # Need to replace with fluentd checks
    #- package_audispd-plugins_installed
    ####
    #- package_scap-security-guide_installed
    - package_audit_installed

    ### Remove Prohibited Packages
    #- package_sendmail_removed
    #- package_iprutils_removed
    #- package_gssproxy_removed
    #- package_nfs-utils_removed
    #- package_krb5-workstation_removed
    #- package_abrt-addon-kerneloops_removed
    #- package_abrt-addon-python_removed
    #- package_abrt-addon-ccpp_removed
    #- package_abrt-plugin-rhtsupport_removed
    #- package_abrt-plugin-logger_removed
    #- package_abrt-plugin-sosreport_removed
    #- package_abrt-cli_removed
    #- package_tuned_removed
    #- package_abrt_removed

    ### Login
    - disable_users_coredumps
    - sysctl_kernel_core_pattern
    - coredump_disable_storage
    - coredump_disable_backtraces
    - service_systemd-coredump_disabled
    #- var_accounts_max_concurrent_login_sessions=10
    #- accounts_max_concurrent_login_sessions
    #- securetty_root_login_console_only
    #- var_password_pam_unix_remember=5
    #- accounts_password_pam_unix_remember

    ### SELinux Configuration
    - var_selinux_state=enforcing
    - selinux_state
    - var_selinux_policy_name=targeted
    - selinux_policytype

    ### Application Whitelisting (RHEL 8)
    - package_fapolicyd_installed
    - service_fapolicyd_enabled

    ### Configure SSSD
    - sssd_run_as_sssd_user

    ### Configure USBGuard
    - service_usbguard_enabled
    - configure_usbguard_auditbackend
    - usbguard_allow_hid_and_hub

    ### Enable / Configure FIPS
    - enable_fips_mode
    - var_system_crypto_policy=fips
    - configure_crypto_policy
    - harden_sshd_crypto_policy
    - harden_ssh_client_crypto_policy
    - configure_openssl_crypto_policy
    - configure_kerberos_crypto_policy

    #######################################################
    ### CONFIGURATION ANNEX TO THE PROTECTION PROFILE
    ### FOR GENERAL PURPOSE OPERATING SYSTEMS
    ### ANNEX RELEASE 1
    ### FOR PROTECTION PROFILE VERSIONS 4.2
    ###
    ### https://www.niap-ccevs.org/MMO/PP/-442ConfigAnnex-/
    #######################################################

    ## Configure Minimum Password Length to 12 Characters
    ## IA-5 (1)(a) / FMT_MOF_EXT.1
    #- var_accounts_password_minlen_login_defs=12
    #- accounts_password_minlen_login_defs
    #- var_password_pam_minlen=12
    #- accounts_password_pam_minlen

    ## Require at Least 1 Special Character in Password
    ## IA-5(1)(a) / FMT_MOF_EXT.1
    #- var_password_pam_ocredit=1
    #- accounts_password_pam_ocredit

    ## Require at Least 1 Numeric Character in Password
    ## IA-5(1)(a) / FMT_MOF_EXT.1
    #- var_password_pam_dcredit=1
    #- accounts_password_pam_dcredit

    ## Require at Least 1 Uppercase Character in Password
    ## IA-5(1)(a) / FMT_MOF_EXT.1
    #- var_password_pam_ucredit=1
    #- accounts_password_pam_ucredit

    ## Require at Least 1 Lowercase Character in Password
    ## IA-5(1)(a) / FMT_MOF_EXT.1
    #- var_password_pam_lcredit=1
    #- accounts_password_pam_lcredit

    ## Enable Screen Lock
    ## FMT_MOF_EXT.1
    #- package_tmux_installed
    #- configure_bashrc_exec_tmux
    #- no_tmux_in_shells
    #- configure_tmux_lock_command
    #- configure_tmux_lock_after_time

    ## Set Screen Lock Timeout Period to 30 Minutes or Less
    ## AC-11(a) / FMT_MOF_EXT.1
    #- sshd_idle_timeout_value=10_minutes
    #- sshd_set_idle_timeout

    ## Disable Unauthenticated Login (such as Guest Accounts)
    ## FIA_UAU.1
    - require_singleuser_auth
    - grub2_disable_interactive_boot
    - grub2_uefi_password
    - no_empty_passwords

    ## Set Maximum Number of Authentication Failures to 3 Within 15 Minutes
    ## AC-7 / FIA_AFL.1
    #- var_accounts_passwords_pam_faillock_deny=3
    #- accounts_passwords_pam_faillock_deny
    #- var_accounts_passwords_pam_faillock_fail_interval=900
    #- accounts_passwords_pam_faillock_interval
    #- var_accounts_passwords_pam_faillock_unlock_time=never
    #- accounts_passwords_pam_faillock_unlock_time
    #- accounts_passwords_pam_faillock_deny_root
    #- accounts_logon_fail_delay

    ## Enable Host-Based Firewall
    ## SC-7(12) / FMT_MOF_EXT.1
    # TODO (Check for iptables and the kubelet config instead)

    ## Configure Name/Addres of Remote Management Server
    ##  From Which to Receive Config Settings
    ## CM-3(3) / FMT_MOF_EXT.1

    ## Configure the System to Offload Audit Records to a Log
    ##  Server
    ## AU-4(1) / FAU_GEN.1.1.c
    #####
    # Need to replace with fluentd checks
    #- auditd_audispd_syslog_plugin_activated
    #####

    ## Set Logon Warning Banner
    ## AC-8(a) / FMT_MOF_EXT.1
    - banner_etc_issue

    ## Audit All Logons (Success/Failure) and Logoffs (Success)
    ##  CNSSI 1253 Value or DoD-Specific Values:
    ##      (1) Logons (Success/Failure)
    ##      (2) Logoffs (Success)
    ## AU-2(a) / FAU_GEN.1.1.c

    ## Audit File and Object Events (Unsuccessful)
    ##  CNSSI 1253 Value or DoD-specific Values:
    ##      (1) Create (Success/Failure)
    ##      (2) Access (Success/Failure)
    ##      (3) Delete (Sucess/Failure)
    ##      (4) Modify (Success/Failure)
    ##      (5) Permission Modification (Sucess/Failure)
    ##      (6) Ownership Modification (Success/Failure)
    ## AU-2(a) / FAU_GEN.1.1.c
    ##
    ##
    ## (1) Create (Success/Failure)
    ##      (open with O_CREAT)
    ## (2) Access (Success/Failure)
    ## (3) Delete (Success/Failure)
    ## (4) Modify (Success/Failure)
    ## (5) Permission Modification (Success/Failure)
    ## (6) Ownership Modification (Success/Failure)

    ## Audit User and Group Management Events (Success/Failure)
    ##  CNSSI 1253 Value or DoD-specific Values:
    ##      (1) User add, delete, modify, disable, enable (Success/Failure)
    ##      (2) Group/Role add, delete, modify (Success/Failure)
    ## AU-2(a) / FAU_GEN.1.1.c
    ##
    ## Generic User and Group Management Events (Success/Failure)
    ## Selection of setuid programs that relate to
    ## user accounts.
    ##
    ## CNSSI 1253: (1) User add, delete, modify, disable, enable (Success/Failure)
    ##
    ## CNSSI 1252: (2) Group/Role add, delete, modify (Success/Failure)
    ##
    ## Audit Privilege or Role Escalation Events (Success/Failure)
    ##  CNSSI 1253 Value or DoD-specific Values:
    ##      - Privilege/Role escalation (Success/Failure)
    ## AU-2(a) / FAU_GEN.1.1.c
    ## Audit All Audit and Log Data Accesses (Success/Failure)
    ##  CNSSI 1253 Value or DoD-specific Values:
    ##      - Audit and log data access (Success/Failure)
    ## AU-2(a) / FAU_GEN.1.1.c
    ## Audit Cryptographic Verification of Software (Success/Failure)
    ##  CNSSI 1253 Value or DoD-specific Values:
    ##      - Applications (e.g. Firefox, Internet Explorer, MS Office Suite,
    ##        etc) initialization (Success/Failure)
    ## AU-2(a) / FAU_GEN.1.1.c
    ## Audit Kernel Module Loading and Unloading Events (Success/Failure)
    ## AU-2(a) / FAU_GEN.1.1.c
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
    - audit_rules_execution_chcon
    - audit_rules_execution_restorecon
    - audit_rules_execution_semanage
    - audit_rules_execution_setfiles
    - audit_rules_execution_setsebool
    - audit_rules_execution_seunshare
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_renameat
    - audit_rules_file_deletion_events_rmdir
    - audit_rules_file_deletion_events_unlink
    - audit_rules_file_deletion_events_unlinkat
    - audit_rules_kernel_module_loading_delete
    - audit_rules_kernel_module_loading_finit
    - audit_rules_kernel_module_loading_init
    - audit_rules_login_events_faillock
    - audit_rules_login_events_lastlog
    - audit_rules_login_events_tallylog
    - audit_rules_mac_modification
    - audit_rules_media_export
    - audit_rules_networkconfig_modification
    - audit_rules_privileged_commands
    - audit_rules_privileged_commands_at
    - audit_rules_privileged_commands_chage
    - audit_rules_privileged_commands_chsh
    - audit_rules_privileged_commands_crontab
    - audit_rules_privileged_commands_gpasswd
    - audit_rules_privileged_commands_mount
    - audit_rules_privileged_commands_newgidmap
    - audit_rules_privileged_commands_newgrp
    - audit_rules_privileged_commands_newuidmap
    - audit_rules_privileged_commands_pam_timestamp_check
    - audit_rules_privileged_commands_passwd
    - audit_rules_privileged_commands_postdrop
    - audit_rules_privileged_commands_postqueue
    - audit_rules_privileged_commands_pt_chown
    - audit_rules_privileged_commands_ssh_keysign
    - audit_rules_privileged_commands_su
    - audit_rules_privileged_commands_sudo
    - audit_rules_privileged_commands_sudoedit
    - audit_rules_privileged_commands_umount
    - audit_rules_privileged_commands_unix_chkpwd
    - audit_rules_privileged_commands_userhelper
    - audit_rules_privileged_commands_usernetctl
    - audit_rules_session_events
    - audit_rules_sysadmin_actions
    - audit_rules_time_adjtimex
    - audit_rules_time_clock_settime
    - audit_rules_time_settimeofday
    - audit_rules_time_stime
    - audit_rules_time_watch_localtime
    - audit_rules_unsuccessful_file_modification_chmod
    - audit_rules_unsuccessful_file_modification_chown
    - audit_rules_unsuccessful_file_modification_creat
    - audit_rules_unsuccessful_file_modification_fchmod
    - audit_rules_unsuccessful_file_modification_fchmodat
    - audit_rules_unsuccessful_file_modification_fchown
    - audit_rules_unsuccessful_file_modification_fchownat
    - audit_rules_unsuccessful_file_modification_fremovexattr
    - audit_rules_unsuccessful_file_modification_fsetxattr
    - audit_rules_unsuccessful_file_modification_ftruncate
    - audit_rules_unsuccessful_file_modification_lchown
    - audit_rules_unsuccessful_file_modification_lremovexattr
    - audit_rules_unsuccessful_file_modification_lsetxattr
    - audit_rules_unsuccessful_file_modification_open
    - audit_rules_unsuccessful_file_modification_openat
    - audit_rules_unsuccessful_file_modification_openat_o_creat
    - audit_rules_unsuccessful_file_modification_openat_o_trunc_write
    - audit_rules_unsuccessful_file_modification_openat_rule_order
    - audit_rules_unsuccessful_file_modification_open_by_handle_at
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_creat
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_trunc_write
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_rule_order
    - audit_rules_unsuccessful_file_modification_open_o_creat
    - audit_rules_unsuccessful_file_modification_open_o_trunc_write
    - audit_rules_unsuccessful_file_modification_open_rule_order
    - audit_rules_unsuccessful_file_modification_removexattr
    - audit_rules_unsuccessful_file_modification_rename
    - audit_rules_unsuccessful_file_modification_renameat
    - audit_rules_unsuccessful_file_modification_setxattr
    - audit_rules_unsuccessful_file_modification_truncate
    - audit_rules_unsuccessful_file_modification_unlink
    - audit_rules_unsuccessful_file_modification_unlinkat
    - audit_rules_usergroup_modification_group
    - audit_rules_usergroup_modification_gshadow
    - audit_rules_usergroup_modification_opasswd
    - audit_rules_usergroup_modification_passwd
    - audit_rules_usergroup_modification_shadow

    ## Enable Automatic Software Updates
    ## SI-2 / FMT_MOF_EXT.1
    # Configure dnf-automatic to Install Only Security Updates
    #- dnf-automatic_security_updates_only

    # Configure dnf-automatic to Install Available Updates Automatically
    #- dnf-automatic_apply_updates

    # Enable dnf-automatic Timer
    #- timer_dnf-automatic_enabled

    # Prevent Kerberos use by system daemons
    #- kerberos_disable_no_keytab

    # AC-18
    - wireless_disable_in_bios
    - wireless_disable_interfaces

    # AC-19
    - grub2_nousb_argument
    - bios_disable_usb_boot
    #- service_autofs_disabled
    #- mount_option_nosuid_removable_partitions
    #- mount_option_nodev_removable_partitions
    #- mount_option_noexec_removable_partitions

    # AC-3
    - sshd_limit_user_access
    - sshd_disable_rhosts
    #- xwindows_runlevel_target
    - grub2_enable_selinux
    #- require_emergency_target_auth
    - no_netrc_files

    # AU-1
    - audit_rules_immutable

    # AU-4
    - auditd_data_retention_action_mail_acct
    - auditd_data_disk_full_action
    - auditd_data_retention_admin_space_left_action
    - auditd_data_retention_space_left_action
    - auditd_data_disk_error_action
    - auditd_data_retention_max_log_file_action
    - auditd_data_retention_space_left

    # AU-8
    - service_chronyd_or_ntpd_enabled
    - chronyd_or_ntpd_specify_remote_server
    - chronyd_or_ntpd_set_maxpoll
    - chronyd_or_ntpd_specify_multiple_servers

    # AU-9
    #- rpm_verify_ownership
    #- rpm_verify_permissions
    - selinux_confinement_of_daemons
    #- ensure_logrotate_activated
    - file_permissions_var_log_audit
    - file_ownership_var_log_audit
    - directory_permissions_var_log_audit

    # AU-11
    - auditd_data_retention_num_logs
    - auditd_data_retention_max_log_file

    # AC-2(5), AC-12
    #- accounts_tmout

    # AC-17
    #- sshd_disable_rhosts_rsa
    #- sshd_disable_user_known_hosts
    #- sshd_do_not_permit_user_env
    #- sshd_print_last_log
    #- sshd_use_priv_separation

    # AC-18(4)
    - network_nmcli_permissions

    # AC-6(5)
    - no_shelllogin_for_systemaccounts
    - no_direct_root_logins

    # AC-6(9)
    - accounts_no_uid_except_zero
    - audit_rules_etc_group_open
    - audit_rules_etc_group_openat
    - audit_rules_etc_group_open_by_handle_at
    - audit_rules_etc_gshadow_open
    - audit_rules_etc_gshadow_openat
    - audit_rules_etc_gshadow_open_by_handle_at
    - audit_rules_etc_passwd_open
    - audit_rules_etc_passwd_openat
    - audit_rules_etc_passwd_open_by_handle_at
    - audit_rules_etc_shadow_open
    - audit_rules_etc_shadow_openat
    - audit_rules_etc_shadow_open_by_handle_at
    - directory_access_var_log_audit
