documentation_complete: true

metadata:
    version: 4.2.1
    SMEs:
        - comps
        - carlosmmatos
        - stevegrubb

reference: https://www.niap-ccevs.org/Profile/PP.cfm

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
    - sshd_set_keepalive
    - sshd_enable_warning_banner
    - sshd_rekey_limit
    - var_rekey_limit_size=1G
    - var_rekey_limit_time=1hour
    - sshd_use_strong_rng
    - openssl_use_strong_entropy

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

    ### umask
    - var_accounts_user_umask=027
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
    - grub2_audit_argument
    - grub2_audit_backlog_limit_argument
    - grub2_slub_debug_argument
    - grub2_page_poison_argument
    - grub2_vsyscall_argument
    - grub2_vsyscall_argument.role=unscored
    - grub2_vsyscall_argument.severity=info
    - grub2_pti_argument
    - grub2_kernel_trust_cpu_rng

    ## Security Settings
    - sysctl_kernel_kptr_restrict
    - sysctl_kernel_dmesg_restrict
    - sysctl_kernel_kexec_load_disabled
    - sysctl_kernel_yama_ptrace_scope
    - sysctl_kernel_perf_event_paranoid
    - sysctl_user_max_user_namespaces
    - sysctl_user_max_user_namespaces.role=unscored
    - sysctl_user_max_user_namespaces.severity=info
    - sysctl_kernel_unprivileged_bpf_disabled
    - sysctl_net_core_bpf_jit_harden
    - service_kdump_disabled

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
    - package_aide_installed
    - package_dnf-automatic_installed
    - package_subscription-manager_installed
    - package_dnf-plugin-subscription-manager_installed
    - package_firewalld_installed
    - package_openscap-scanner_installed
    - package_policycoreutils_installed
    - package_sudo_installed
    - package_usbguard_installed
    - package_scap-security-guide_installed
    - package_audit_installed
    - package_crypto-policies_installed
    - package_openssh-server_installed
    - package_openssh-clients_installed
    - package_policycoreutils-python-utils_installed
    - package_rsyslog_installed
    - package_rsyslog-gnutls_installed
    - package_audispd-plugins_installed
    - package_chrony_installed
    - package_gnutls-utils_installed

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
    - use_pam_wheel_for_su

    ### SELinux Configuration
    - var_selinux_state=enforcing
    - selinux_state
    - var_selinux_policy_name=targeted
    - selinux_policytype

    ### Application Whitelisting (RHEL 8)
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
    - configure_bind_crypto_policy
    - configure_openssl_crypto_policy
    - configure_libreswan_crypto_policy
    - configure_kerberos_crypto_policy
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
    - configure_bashrc_exec_tmux
    - no_tmux_in_shells
    - configure_tmux_lock_command
    - configure_tmux_lock_after_time

    ## Set Screen Lock Timeout Period to 30 Minutes or Less
    ## AC-11(a) / FMT_MOF_EXT.1
    ## We deliberately set sshd timeout to 1 minute before tmux lock timeout
    - sshd_idle_timeout_value=14_minutes
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
    # temporarily dropped

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
    - audit_basic_configuration
    - audit_immutable_login_uids
    - audit_create_failed
    - audit_create_success
    - audit_modify_failed
    - audit_modify_success
    - audit_access_failed
    - audit_access_success
    - audit_delete_failed
    - audit_delete_success
    - audit_perm_change_failed
    - audit_perm_change_success
    - audit_owner_change_failed
    - audit_owner_change_success
    - audit_ospp_general
    - audit_module_load

    ## Enable Automatic Software Updates
    ## SI-2 / FMT_MOF_EXT.1
    # Configure dnf-automatic to Install Only Security Updates
    - dnf-automatic_security_updates_only

    # Configure dnf-automatic to Install Available Updates Automatically
    - dnf-automatic_apply_updates

    # Enable dnf-automatic Timer
    - timer_dnf-automatic_enabled

    # Configure TLS for remote logging
    - rsyslog_remote_tls
    - rsyslog_remote_tls_cacert

    # Prevent Kerberos use by system daemons
    - kerberos_disable_no_keytab

    # set ssh client rekey limit
    - ssh_client_rekey_limit
    - var_ssh_client_rekey_limit_size=1G
    - var_ssh_client_rekey_limit_time=1hour

# configure ssh client to use strong entropy
    - ssh_client_use_strong_rng_sh
    - ssh_client_use_strong_rng_csh

    # zIPl specific rules
    - zipl_bls_entries_only
    - zipl_bootmap_is_up_to_date
    - zipl_audit_argument
    - zipl_audit_backlog_limit_argument
    - zipl_slub_debug_argument
    - zipl_page_poison_argument
    - zipl_vsyscall_argument
    - zipl_vsyscall_argument.role=unscored
    - zipl_vsyscall_argument.severity=info
