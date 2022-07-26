documentation_complete: true

metadata:
    version: 4.2.1
    SMEs:
        - comps
        - stevegrubb

reference: https://www.niap-ccevs.org/Profile/Info.cfm?PPID=442&id=442

title: 'Protection Profile for General Purpose Operating Systems'

description: |-
    This profile is part of Red Hat Enterprise Linux 9 Common Criteria Guidance
    documentation for Target of Evaluation based on Protection Profile for
    General Purpose Operating Systems (OSPP) version 4.2.1 and Functional
    Package for SSH version 1.0.

    Where appropriate, CNSSI 1253 or DoD-specific values are used for
    configuration, based on Configuration Annex to the OSPP.

selections:

    #######################################################
    ### GENERAL REQUIREMENTS
    ### Things needed to meet OSPP functional requirements.
    #######################################################

    ### Partitioning
    - partition_for_var_log_audit
    - mount_option_var_log_audit_nodev
    - mount_option_var_log_audit_nosuid
    - mount_option_var_log_audit_noexec

    ### Services
    # sshd
    - sshd_use_directory_configuration
    - sshd_disable_root_login
    - disable_host_auth
    - sshd_disable_empty_passwords
    - sshd_disable_kerb_auth
    - sshd_disable_gssapi_auth
    - sshd_rekey_limit
    - var_rekey_limit_size=1G
    - var_rekey_limit_time=1hour

    # Time Server
    - chronyd_client_only

    ### systemd
    - disable_ctrlaltdel_reboot
    - disable_ctrlaltdel_burstaction
    - service_debug-shell_disabled
    - grub2_systemd_debug-shell_argument_absent

    ### Software update
    - ensure_redhat_gpgkey_installed
    - ensure_gpgcheck_globally_activated
    - ensure_gpgcheck_local_packages
    - ensure_gpgcheck_never_disabled

    ### Kernel Config
    ## Boot prompt
    - grub2_audit_argument
    - grub2_audit_backlog_limit_argument
    - grub2_vsyscall_argument
    - grub2_init_on_alloc_argument
    - grub2_page_alloc_shuffle_argument

    ## Security Settings
    - sysctl_kernel_kptr_restrict
    - sysctl_kernel_dmesg_restrict
    - sysctl_kernel_kexec_load_disabled
    - sysctl_kernel_yama_ptrace_scope
    - sysctl_kernel_perf_event_paranoid
    - sysctl_user_max_user_namespaces
    - sysctl_kernel_unprivileged_bpf_disabled
    - sysctl_net_core_bpf_jit_harden
    - service_kdump_disabled

    ### Audit
    - service_auditd_enabled
    - var_auditd_flush=incremental_async
    - auditd_data_retention_flush
    - auditd_log_format
    - auditd_freq
    - auditd_name_format

    ### Module Blacklist
    - kernel_module_bluetooth_disabled
    - kernel_module_sctp_disabled
    - kernel_module_can_disabled
    - kernel_module_tipc_disabled

    ### rpcbind

    ### Install Required Packages
    - package_dnf-automatic_installed
    - package_subscription-manager_installed
    - package_firewalld_installed
    - package_openscap-scanner_installed
    - package_sudo_installed
    - package_usbguard_installed
    - package_scap-security-guide_installed
    - package_audit_installed
    - package_crypto-policies_installed
    - package_openssh-server_installed
    - package_openssh-clients_installed
    - package_chrony_installed
    - package_gnutls-utils_installed

    ### Login
    - disable_users_coredumps
    - sysctl_kernel_core_pattern
    - coredump_disable_storage
    - coredump_disable_backtraces
    - service_systemd-coredump_disabled
    - var_authselect_profile=sssd
    - enable_authselect
    - use_pam_wheel_for_su

    ### SELinux Configuration
    - var_selinux_state=enforcing
    - selinux_state
    - var_selinux_policy_name=targeted
    - selinux_policytype

    ### Application Whitelisting (RHEL 9)
    - package_fapolicyd_installed
    - service_fapolicyd_enabled

    ### Configure USBGuard
    - service_usbguard_enabled
    - configure_usbguard_auditbackend
    - usbguard_allow_hid_and_hub


    ### Enable / Configure FIPS
    - enable_fips_mode
    - var_system_crypto_policy=fips_ospp
    - configure_crypto_policy
    - configure_ssh_crypto_policy
    - configure_openssl_crypto_policy
    - enable_dracut_fips_module

    #######################################################
    ### CONFIGURATION ANNEX TO THE PROTECTION PROFILE
    ### FOR GENERAL PURPOSE OPERATING SYSTEMS
    ### ANNEX RELEASE 1
    ### FOR PROTECTION PROFILE VERSIONS 4.2
    ###
    ### https://www.niap-ccevs.org/MMO/PP/-442ConfigAnnex-/
    #######################################################

    ## Configure Minimum Password Length to 12 Characters
    ## IA-5 (1)(a) / FMT_MOF_EXT.1 (FMT_SMF_EXT.1)
    - var_password_pam_minlen=12
    - accounts_password_pam_minlen

    ## Require at Least 1 Special Character in Password
    ## IA-5(1)(a) / FMT_MOF_EXT.1 (FMT_SMF_EXT.1)
    - var_password_pam_ocredit=1
    - accounts_password_pam_ocredit

    ## Require at Least 1 Numeric Character in Password
    ## IA-5(1)(a) / FMT_MOF_EXT.1 (FMT_SMF_EXT.1)
    - var_password_pam_dcredit=1
    - accounts_password_pam_dcredit

    ## Require at Least 1 Uppercase Character in Password
    ## IA-5(1)(a) / FMT_MOF_EXT.1 (FMT_SMF_EXT.1)
    - var_password_pam_ucredit=1
    - accounts_password_pam_ucredit

    ## Require at Least 1 Lowercase Character in Password
    ## IA-5(1)(a) / FMT_MOF_EXT.1 (FMT_SMF_EXT.1)
    - var_password_pam_lcredit=1
    - accounts_password_pam_lcredit

    ## Enable Screen Lock
    ## FMT_MOF_EXT.1 (FMT_SMF_EXT.1)
    - package_tmux_installed
    - configure_bashrc_exec_tmux
    - no_tmux_in_shells
    - configure_tmux_lock_command

    ## Set Screen Lock Timeout Period to 30 Minutes or Less
    ## AC-11(a) / FMT_MOF_EXT.1 (FMT_SMF_EXT.1)
    - configure_tmux_lock_after_time

    ## Disable Unauthenticated Login (such as Guest Accounts)
    ## FIA_UAU.1
    - require_singleuser_auth
    - grub2_disable_recovery
    - grub2_uefi_password
    - no_empty_passwords

    ## Set Maximum Number of Authentication Failures to 3 Within 15 Minutes
    ## AC-7 / FIA_AFL.1
    - var_accounts_passwords_pam_faillock_deny=3
    - accounts_passwords_pam_faillock_deny
    - var_accounts_passwords_pam_faillock_fail_interval=900
    - accounts_passwords_pam_faillock_interval
    - var_accounts_passwords_pam_faillock_unlock_time=never
    - accounts_passwords_pam_faillock_unlock_time

    ## Enable Host-Based Firewall
    ## SC-7(12) / FMT_MOF_EXT.1 (FMT_SMF_EXT.1)
    - service_firewalld_enabled

    ## Configure Name/Addres of Remote Management Server
    ##  From Which to Receive Config Settings
    ## CM-3(3) / FMT_MOF_EXT.1
    # Management server not selected in FTP_ITC_EXT.1

    ## Configure the System to Offload Audit Records to a Log
    ##  Server
    ## AU-4(1) / FAU_GEN.1.1.c
    # Audit server not selected in FTP_ITC_EXT.1

    ## Set Logon Warning Banner
    ## AC-8(a) / FMT_MOF_EXT.1 (FTA_TAB.1)
    - sshd_enable_warning_banner

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
    - audit_basic_configuration
    - audit_immutable_login_uids
    - audit_create_failed
    - audit_create_failed_aarch64
    - audit_create_success
    - audit_create_success_aarch64
    - audit_modify_failed
    - audit_modify_failed_aarch64
    - audit_modify_success
    - audit_modify_success_aarch64
    - audit_access_failed
    - audit_access_failed_aarch64
    - audit_access_success
    - audit_access_success.severity=info
    - audit_access_success.role=unscored
    - audit_access_success_aarch64
    - audit_access_success_aarch64.severity=info
    - audit_access_success_aarch64.role=unscored
    - audit_delete_failed
    - audit_delete_failed_aarch64
    - audit_delete_success
    - audit_delete_success_aarch64
    - audit_perm_change_failed
    - audit_perm_change_failed_aarch64
    - audit_perm_change_success
    - audit_perm_change_success_aarch64
    - audit_owner_change_failed
    - audit_owner_change_failed_aarch64
    - audit_owner_change_success
    - audit_owner_change_success_aarch64
    - audit_ospp_general
    - audit_ospp_general_aarch64
    - audit_module_load

    ## Enable Automatic Software Updates
    ## SI-2 / FMT_MOF_EXT.1 (FMT_SMF_EXT.1)
    # Configure dnf-automatic to Install Available Updates Automatically
    - dnf-automatic_apply_updates

    # Enable dnf-automatic Timer
    - timer_dnf-automatic_enabled

    # set ssh client rekey limit
    - ssh_client_rekey_limit
    - var_ssh_client_rekey_limit_size=1G
    - var_ssh_client_rekey_limit_time=1hour

    # zIPl specific rules
    - zipl_bls_entries_only
    - zipl_bootmap_is_up_to_date
    - zipl_audit_argument
    - zipl_audit_backlog_limit_argument
    - zipl_init_on_alloc_argument
    - zipl_page_alloc_shuffle_argument
    - zipl_systemd_debug-shell_argument_absent
