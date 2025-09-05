documentation_complete: true

metadata:
    version: 4.2.1
    SMEs:
        - comps
        - carlosmmatos
        - stevegrubb

reference: https://www.niap-ccevs.org/Profile/PP.cfm

title: 'OSPP - Protection Profile for General Purpose Operating Systems v4.2.1'

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

    ### Services
    # sshd
    - sshd_disable_root_login
    - sshd_enable_strictmodes
    - disable_host_auth
    - sshd_disable_empty_passwords
    - sshd_disable_kerb_auth
    - sshd_disable_gssapi_auth
    - sshd_set_keepalive
    - sshd_enable_warning_banner
    - sshd_disable_rhosts_rsa
    - sshd_use_approved_ciphers
    - sshd_use_approved_macs

    # Time Server

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
    - service_kdump_disabled
    - service_autofs_disabled

    ### umask
    - accounts_umask_etc_profile
    - accounts_umask_etc_bashrc
    - accounts_umask_etc_csh_cshrc

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
    - package_dracut-fips_installed
    - grub2_audit_argument
    - grub2_audit_backlog_limit_argument
    - grub2_slub_debug_argument
    - grub2_page_poison_argument
    - grub2_vsyscall_argument

    ## Security Settings
    - sysctl_kernel_kptr_restrict
    - sysctl_kernel_dmesg_restrict
    - sysctl_kernel_kexec_load_disabled
    - sysctl_kernel_yama_ptrace_scope

    ## File System Settings
    - sysctl_fs_protected_hardlinks
    - sysctl_fs_protected_symlinks

    ### Audit
    - service_auditd_enabled
    - var_auditd_flush=incremental_async
    - auditd_data_retention_flush

    ### Misc Audit Configuration
    ### (not required in OSPP)

    ### Module Blacklist
    - kernel_module_usb-storage_disabled
    - kernel_module_cramfs_disabled
    - kernel_module_bluetooth_disabled
    - kernel_module_dccp_disabled
    - kernel_module_sctp_disabled

    ### rpcbind
    - service_rpcbind_disabled

    ### Install Required Packages

    ### Remove Prohibited Packages
    - package_abrt_removed

    ### Login
    - disable_users_coredumps
    - var_accounts_max_concurrent_login_sessions=10
    - accounts_max_concurrent_login_sessions
    - securetty_root_login_console_only
    - var_password_pam_unix_remember=5
    - accounts_password_pam_unix_remember

    ### SELinux Configuration

    ### Application Whitelisting (RHEL 8)

    ### Configure SSSD

    ### Configure USBGuard

    ### Enable / Configure FIPS
    -  grub2_enable_fips_mode

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
    - package_screen_installed

    ## Set Screen Lock Timeout Period to 30 Minutes or Less
    ## AC-11(a) / FMT_MOF_EXT.1
    - sshd_idle_timeout_value=10_minutes
    - sshd_set_idle_timeout

    ## Disable Unauthenticated Login (such as Guest Accounts)
    ## FIA_UAU.1
    - require_singleuser_auth
    - grub2_disable_interactive_boot
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
    ## SC-7(12) / FMT_MOF_EXT.1
    - service_firewalld_enabled

    ## Configure Name/Addres of Remote Management Server
    ##  From Which to Receive Config Settings
    ## CM-3(3) / FMT_MOF_EXT.1

    ## Configure the System to Offload Audit Records to a Log
    ##  Server
    ## AU-4(1) / FAU_GEN.1.1.c

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
    - audit_rules_for_ospp


    ###  SELinux Configuration

    # Ensure SELinux is Enforcing
    - var_selinux_state=enforcing
    - selinux_state

    # Configure SELinux Policy
    - var_selinux_policy_name=targeted
    - selinux_policytype
