documentation_complete: true

title: 'Protection Profile for General Purpose Operating Systems'

description: |-
    This profile reflects mandatory configuration controls identified in the
    NIAP Configuration Annex to the Protection Profile for General Purpose
    Operating Systems (Protection Profile Version 4.2.1).

    This configuration profile is consistent with CNSSI-1253, which requires
    U.S. National Security Systems to adhere to certain configuration
    parameters. Accordingly, this configuration profile is suitable for
    use in U.S. National Security Systems.

selections:

    #######################################################
    ### GENERAL REQUIREMENTS
    ### Things needed to meet OSPP functional requirements.
    #######################################################

    ### Partitioning
    - mount_option_home_nodev
    - mount_option_home_nosuid
    - mount_option_tmp_nodev
    - mount_option_tmp_noexec
    - mount_option_tmp_nosuid
    - mount_option_var_tmp_nodev
    - mount_option_var_tmp_noexec
    - mount_option_var_tmp_nosuid
    - mount_option_dev_shm_nodev
    - mount_option_dev_shm_noexec
    - mount_option_dev_shm_nosuid
    - mount_option_nodev_nonroot_local_partitions
    - mount_option_boot_nodev
    - mount_option_boot_nosuid
    - partition_for_home
    - partition_for_var
    - mount_option_var_nodev
    - partition_for_var_log
    - mount_option_var_log_nodev
    - mount_option_var_log_nosuid
    - mount_option_var_log_noexec
    - partition_for_var_log_audit
    - mount_option_var_log_audit_nodev
    - mount_option_var_log_audit_nosuid
    - mount_option_var_log_audit_noexec

    ### Services
    # sshd
    - sshd_disable_root_login
    - sshd_enable_strictmodes
    - disable_host_auth
    - sshd_disable_empty_passwords
    - sshd_disable_kerb_auth
    - sshd_disable_gssapi_auth
    - var_sshd_set_keepalive=0
    - sshd_set_keepalive
    - sshd_enable_warning_banner
    #- sshd_disable_rhosts_rsa
    #- sshd_use_approved_ciphers
    #- sshd_use_approved_macs
    - sshd_rekey_limit

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
    - sysctl_net_ipv4_ip_forward
    - sysctl_net_ipv4_tcp_syncookies

    ### systemd
    - disable_ctrlaltdel_reboot
    - disable_ctrlaltdel_burstaction
    - service_debug-shell_disabled
    #- service_kdump_disabled
    #- service_autofs_disabled

    ### umask
    - var_accounts_user_umask=027
    - accounts_umask_etc_profile
    - accounts_umask_etc_bashrc
    - accounts_umask_etc_csh_cshrc
    #- accounts_umask_etc_login_defs

    ### Software update
    - ensure_redhat_gpgkey_installed
    - ensure_gpgcheck_globally_activated
    - ensure_gpgcheck_local_packages
    - ensure_gpgcheck_never_disabled

    ### Passwords
    - var_password_pam_difok=4
    - accounts_password_pam_difok
    - var_password_pam_maxrepeat=3
    - accounts_password_pam_maxrepeat
    - var_password_pam_maxclassrepeat=4
    - accounts_password_pam_maxclassrepeat

    ### Kernel Config
    ## Boot prompt
    #- package_dracut-fips_installed
    - grub2_audit_argument
    - grub2_audit_backlog_limit_argument
    - grub2_slub_debug_argument
    - grub2_page_poison_argument
    - grub2_vsyscall_argument
    - grub2_pti_argument

    ## Security Settings
    - sysctl_kernel_kptr_restrict
    - sysctl_kernel_dmesg_restrict
    - sysctl_kernel_kexec_load_disabled
    - sysctl_kernel_yama_ptrace_scope
    - sysctl_kernel_perf_event_paranoid
    - sysctl_user_max_user_namespaces
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

    ### Misc Audit Configuration
    ### (not required in OSPP)
    - audit_rules_session_events
    - audit_rules_mac_modification

    ### Module Blacklist
    #- kernel_module_usb-storage_disabled
    - kernel_module_cramfs_disabled
    - kernel_module_bluetooth_disabled
    #- kernel_module_dccp_disabled
    - kernel_module_sctp_disabled
    - kernel_module_firewire-core_disabled
    - kernel_module_atm_disabled
    - kernel_module_can_disabled
    - kernel_module_tipc_disabled

    ### rpcbind
    #- service_rpcbind_disabled

    ### Install Required Packages
    - package_sssd-ipa_installed
    - package_aide_installed
    - package_dnf-automatic_installed
    - package_firewalld_installed
    - package_iptables_installed
    - package_libcap-ng-utils_installed
    - package_openscap-scanner_installed
    - package_policycoreutils_installed
    - package_python3-subscription-manager-rhsm_installed
    - package_rng-tools_installed
    - package_sudo_installed
    - package_usbguard_installed
    - package_audispd-plugins_installed
    - package_scap-security-guide_installed
    - package_auditd_installed
    - package_libreswan_installed
    - package_rsyslog_installed

    ### Remove Prohibited Packages
    - package_sendmail_removed
    - package_iprutils_removed
    - package_gssproxy_removed
    - package_nfs-utils_removed
    - package_krb5-workstation_removed
    - package_abrt-addon-kerneloops_removed
    - package_abrt-addon-python_removed
    - package_abrt-addon-ccpp_removed
    - package_abrt-plugin-rhtsupport_removed
    - package_abrt-plugin-logger_removed
    - package_abrt-plugin-sosreport_removed
    - package_abrt-cli_removed
    - package_tuned_removed
    - package_abrt_removed

    ### Login
    - disable_users_coredumps
    - sysctl_kernel_core_pattern
    - coredump_disable_storage
    - coredump_disable_backtraces
    - service_systemd-coredump_disabled
    - var_accounts_max_concurrent_login_sessions=10
    - accounts_max_concurrent_login_sessions
    - securetty_root_login_console_only
    - var_password_pam_unix_remember=5
    - accounts_password_pam_unix_remember

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
    
    ### Enable / Configure FIPS
    #- grub2_enable_fips_mode
    - enable_fips_mode
    - var_system_crypto_policy=fips
    - configure_crypto_policy
    - harden_sshd_crypto_policy 
    - configure_bind_crypto_policy
    - configure_openssl_crypto_policy
    - configure_libreswan_crypto_policy
    - configure_kerberos_crypto_policy
    #- sysctl_crypto_fips_enabled
    - enable_dracut_fips_module
    #- etc_system_fips_exists

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
    - var_accounts_password_minlen_login_defs=12
    - accounts_password_minlen_login_defs
    - var_password_pam_minlen=12
    - accounts_password_pam_minlen

    ## Require at Least 1 Special Character in Password
    ## IA-5(1)(a) / FMT_MOF_EXT.1
    - var_password_pam_ocredit=1
    - accounts_password_pam_ocredit

    ## Require at Least 1 Numeric Character in Password
    ## IA-5(1)(a) / FMT_MOF_EXT.1
    - var_password_pam_dcredit=1
    - accounts_password_pam_dcredit

    ## Require at Least 1 Uppercase Character in Password
    ## IA-5(1)(a) / FMT_MOF_EXT.1
    - var_password_pam_ucredit=1
    - accounts_password_pam_ucredit

    ## Require at Least 1 Lowercase Character in Password
    ## IA-5(1)(a) / FMT_MOF_EXT.1
    - var_password_pam_lcredit=1
    - accounts_password_pam_lcredit

    ## Enable Screen Lock
    ## FMT_MOF_EXT.1
    - package_tmux_installed
    - configure_tmux_lock_command

    ## Set Screen Lock Timeout Period to 30 Minutes or Less
    ## AC-11(a) / FMT_MOF_EXT.1
    - sshd_idle_timeout_value=10_minutes
    - sshd_set_idle_timeout

    ## Disable Unauthenticated Login (such as Guest Accounts)
    ## FIA_AFL.1
    - require_singleuser_auth
    - grub2_disable_interactive_boot
    - grub2_uefi_password
    - no_empty_passwords

    ## Set Maximum Number of Authentication Failures to 3 Within 15 Minutes
    ## AC-7(a) / FMT_MOF_EXT.1
    - var_accounts_passwords_pam_faillock_deny=3
    - accounts_passwords_pam_faillock_deny
    - var_accounts_passwords_pam_faillock_fail_interval=900
    - accounts_passwords_pam_faillock_interval
    - var_accounts_passwords_pam_faillock_unlock_time=never
    - accounts_passwords_pam_faillock_unlock_time

    ## Enable Host-Based Firewall
    ## SC-7(12) / FMT_MOF_EXT.1
    - service_firewalld_enabled

    ## Configure Name/Addres of Remote Management Server
    ##  From Which to Receive Config Settings
    ## CM-3(3) / FMT_MOF_EXT.1

    ## Configure the System to Offload Audit Records to a Log
    ##  Server
    ## AU-4(1) / FAU_GEN.1.1.c
    - auditd_audispd_syslog_plugin_activated

    ## Set Logon Warning Banner
    ## AC-8(a) / FMT_MOF_EXT.1

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
    ##
    # openat O_CREAT
    - audit_rules_unsuccessful_file_modification_openat_o_creat
    - audit_rules_successful_file_modification_openat_o_creat

    # open_by_handle_at O_CREAT
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_creat
    - audit_rules_successful_file_modification_open_by_handle_at_o_creat

    # open O_CREAT
    - audit_rules_unsuccessful_file_modification_open_o_creat
    - audit_rules_successful_file_modification_open_o_creat

    ##
    ## (4) Modify (Success/Failure)
    ##
    ##  NOTE: THESE RULES *MUST* BE ORDERED PRIOR TO
    ##        THE STANDARD FILE ACCESS RULES (e.g. open, creat, etc)
    ##
    # openat O_TRUNC_WRITE
    - audit_rules_unsuccessful_file_modification_openat_o_trunc_write
    - audit_rules_successful_file_modification_openat_o_trunc_write

    # open_by_handle_at O_TRUNC_WRITE
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_trunc_write
    - audit_rules_successful_file_modification_open_by_handle_at_o_trunc_write

    # open O_TRUNC_WRITE
    - audit_rules_unsuccessful_file_modification_open_o_trunc_write
    - audit_rules_successful_file_modification_open_o_trunc_write

    ##
    ## (2) Access (Success/Failure)
    ##
    # open
    - audit_rules_unsuccessful_file_modification_open
    - audit_rules_successful_file_modification_open

    # creat
    - audit_rules_unsuccessful_file_modification_creat
    - audit_rules_successful_file_modification_creat

    # truncate
    - audit_rules_unsuccessful_file_modification_truncate
    - audit_rules_successful_file_modification_truncate

    # ftruncate
    - audit_rules_unsuccessful_file_modification_ftruncate
    - audit_rules_successful_file_modification_ftruncate

    # openat
    - audit_rules_unsuccessful_file_modification_openat
    - audit_rules_successful_file_modification_openat

    # open_by_handle_at
    - audit_rules_unsuccessful_file_modification_open_by_handle_at
    - audit_rules_successful_file_modification_open_by_handle_at

    ##
    ## (3) Delete (Success/Failure)
    ##
    # unlink
    - audit_rules_unsuccessful_file_modification_unlink
    - audit_rules_successful_file_modification_unlink

    # unlinkat
    - audit_rules_unsuccessful_file_modification_unlinkat
    - audit_rules_successful_file_modification_unlinkat

    # rename
    - audit_rules_unsuccessful_file_modification_rename
    - audit_rules_successful_file_modification_rename

    # renameat
    - audit_rules_unsuccessful_file_modification_renameat
    - audit_rules_successful_file_modification_renameat

    ##
    ## (5) Permission Modification (Success/Failure)
    ##
    - audit_rules_unsuccessful_file_modification_chmod
    - audit_rules_successful_file_modification_chmod
    - audit_rules_unsuccessful_file_modification_fchmod
    - audit_rules_successful_file_modification_fchmod
    - audit_rules_unsuccessful_file_modification_fchmodat
    - audit_rules_successful_file_modification_fchmodat
    - audit_rules_unsuccessful_file_modification_setxattr
    - audit_rules_successful_file_modification_setxattr
    - audit_rules_unsuccessful_file_modification_lsetxattr
    - audit_rules_successful_file_modification_lsetxattr
    - audit_rules_unsuccessful_file_modification_fsetxattr
    - audit_rules_successful_file_modification_fsetxattr
    - audit_rules_unsuccessful_file_modification_removexattr
    - audit_rules_successful_file_modification_removexattr
    - audit_rules_unsuccessful_file_modification_lremovexattr
    - audit_rules_successful_file_modification_lremovexattr
    - audit_rules_unsuccessful_file_modification_fremovexattr
    - audit_rules_successful_file_modification_fremovexattr

    ##
    ## (6) Ownership Modification (Success/Failure)
    ##
    - audit_rules_unsuccessful_file_modification_lchown
    - audit_rules_successful_file_modification_lchown
    - audit_rules_unsuccessful_file_modification_fchown
    - audit_rules_successful_file_modification_fchown
    - audit_rules_unsuccessful_file_modification_chown
    - audit_rules_successful_file_modification_chown
    - audit_rules_unsuccessful_file_modification_fchownat
    - audit_rules_successful_file_modification_fchownat


    ## Audit User and Group Management Events (Success/Failure)
    ##  CNSSI 1253 Value or DoD-specific Values:
    ##      (1) User add, delete, modify, disable, enable (Success/Failure)
    ##      (2) Group/Role add, delete, modify (Success/Failure)
    ## AU-2(a) / FAU_GEN.1.1.c
    ##
    ## Generic User and Group Management Events (Success/Failure)
    ## Selection of setuid programs that relate to
    ## user accounts.
    - audit_rules_privileged_commands_gpasswd
    - audit_rules_privileged_commands_newgidmap
    - audit_rules_privileged_commands_newgrp
    - audit_rules_privileged_commands_newuidmap
    - audit_rules_privileged_commands_passwd
    - audit_rules_privileged_commands_unix_chkpwd
    - audit_rules_privileged_commands_at
    - audit_rules_privileged_commands_crontab
    - audit_rules_privileged_commands_mount
    - audit_rules_execution_seunshare
    - audit_rules_privileged_commands_umount
    - audit_rules_privileged_commands_userhelper
    - audit_rules_privileged_commands_usernetctl

    ##
    ## CNSSI 1253: (1) User add, delete, modify, disable, enable (Success/Failure)
    ##
    # Record Events that Modify User/Group Information via openat syscall - /etc/passwd
    - audit_rules_etc_passwd_openat

    # Record Events that Modify User/Group Information via open_by_handle_at syscall - /etc/passwd
    - audit_rules_etc_passwd_open_by_handle_at

    # Record Events that Modify User/Group Information via open syscall - /etc/passwd
    - audit_rules_etc_passwd_open

    # Record Events that Modify User/Group Information via openat syscall - /etc/shadow
    - audit_rules_etc_shadow_openat

    # Record Events that Modify User/Group Information via open_by_handle_at syscall - /etc/shadow
    - audit_rules_etc_shadow_open_by_handle_at

    # Record Events that Modify User/Group Information via open syscall - /etc/shadow
    - audit_rules_etc_shadow_open

    ##
    ## CNSSI 1252: (2) Group/Role add, delete, modify (Success/Failure)
    ## 
    - audit_rules_usergroup_modification_group
    - audit_rules_usergroup_modification_gshadow
    - audit_rules_usergroup_modification_passwd
    - audit_rules_usergroup_modification_shadow
    
    ## Audit Privilege or Role Escalation Events (Success/Failure)
    ##  CNSSI 1253 Value or DoD-specific Values:
    ##      - Privilege/Role escalation (Success/Failure)
    ## AU-2(a) / FAU_GEN.1.1.c

    ## Audit All Audit and Log Data Accesses (Success/Failure)
    ##  CNSSI 1253 Value or DoD-specific Values:
    ##      - Audit and log data access (Success/Failure)
    ## AU-2(a) / FAU_GEN.1.1.c
    - directory_access_var_log_audit

    ## Audit Cryptographic Verification of Software (Success/Failure)
    ##  CNSSI 1253 Value or DoD-specific Values:
    ##      - Applications (e.g. Firefox, Internet Explorer, MS Office Suite,
    ##        etc) initialization (Success/Failure)
    ## AU-2(a) / FAU_GEN.1.1.c

    ## Audit Kernel Module Loading and Unloading Events (Success/Failure)
    ## AU-2(a) / FAU_GEN.1.1.c
    - audit_rules_kernel_module_loading_init
    - audit_rules_kernel_module_loading_finit
    - audit_rules_kernel_module_loading_delete

    ## Enable Automatic Software Updates
    ## SI-2 / FMT_MOF_EXT.1
    # Configure dnf-automatic to Install Only Security Updates
    - dnf-automatic_security_updates_only

    # Configure dnf-automatic to Install Available Updates Automatically
    - dnf-automatic_apply_updates

    # Enable dnf-automatic Timer
    - timer_dnf-automatic_enabled

