documentation_complete: true

title: 'United States Government Configuration Baseline'

description: |-
    This compliance profile reflects the core set of security
    related configuration settings for deployment of Red Hat Enterprise
    Linux 7.x into U.S. Defense, Intelligence, and Civilian agencies.
    Development partners and sponsors include the U.S. National Institute
    of Standards and Technology (NIST), U.S. Department of Defense,
    the National Security Agency, and Red Hat.

    This baseline implements configuration requirements from the following
    sources:

    - Committee on National Security Systems Instruction No. 1253 (CNSSI 1253)
    - NIST Controlled Unclassified Information (NIST 800-171)
    - NIST 800-53 control selections for MODERATE impact systems (NIST 800-53)
    - U.S. Government Configuration Baseline (USGCB)
    - NIAP Protection Profile for General Purpose Operating Systems v4.2.1 (OSPP v4.2.1)
    - DISA Operating System Security Requirements Guide (OS SRG)

    For any differing configuration requirements, e.g. password lengths, the stricter
    security setting was chosen. Security Requirement Traceability Guides (RTMs) and
    sample System Security Configuration Guides are provided via the
    scap-security-guide-docs package.

    This profile reflects U.S. Government consensus content and is developed through
    the OpenSCAP/SCAP Security Guide initiative, championed by the National
    Security Agency. Except for differences in formatting to accommodate
    publishing processes, this profile mirrors OpenSCAP/SCAP Security Guide
    content as minor divergences, such as bugfixes, work through the
    consensus and release processes.

selections:
    ### Boot
    - grub2_uefi_password

    # systemd
    - require_singleuser_auth
    - grub2_disable_interactive_boot
    - disable_ctrlaltdel_reboot
    - disable_ctrlaltdel_burstaction
    - service_debug-shell_disabled
    - service_kdump_disabled
    - service_autofs_disabled

    # Partitioning
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

    ### Kernel Config

    # Boot prompt
    - package_dracut-fips_installed
    - grub2_enable_fips_mode
    - grub2_audit_argument
    - grub2_audit_backlog_limit_argument
    - grub2_slub_debug_argument
    - grub2_page_poison_argument
    - grub2_vsyscall_argument

    # Security Settings
    - sysctl_kernel_kptr_restrict
    - sysctl_kernel_dmesg_restrict
    - sysctl_kernel_kexec_load_disabled
    - sysctl_kernel_yama_ptrace_scope

    # File System Settings
    - sysctl_fs_protected_hardlinks
    - sysctl_fs_protected_symlinks

    # Network Settings
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

    # Module blacklist
    - kernel_module_usb-storage_disabled
    - kernel_module_cramfs_disabled
    - kernel_module_bluetooth_disabled
    - kernel_module_dccp_disabled
    - kernel_module_sctp_disabled

    ### Audit
    - service_auditd_enabled

    # Rules.d
    - directory_access_var_log_audit

    # Configuration (all are defaults)
    - var_auditd_flush=incremental_async
    - auditd_data_retention_flush

    ### Services

    # sshd
    - sshd_disable_root_login
    - sshd_enable_strictmodes
    - disable_host_auth
    - sshd_disable_user_known_hosts
    - sshd_disable_rhosts
    - sshd_disable_empty_passwords
    - sshd_disable_kerb_auth
    - sshd_disable_gssapi_auth
    - sshd_idle_timeout_value=10_minutes
    - sshd_set_keepalive
    - sshd_enable_warning_banner
    - sshd_disable_rhosts_rsa
    - sshd_use_approved_ciphers
    - sshd_use_approved_macs

    # rpcbind
    - service_rpcbind_disabled

    # Firewalld
    - service_firewalld_enabled

    # abrt
    - package_abrt_removed

    ### User sessions

    # Login
    - no_empty_passwords
    - var_accounts_passwords_pam_faillock_deny=3
    - accounts_passwords_pam_faillock_deny
    - var_accounts_passwords_pam_faillock_fail_interval=900
    - accounts_passwords_pam_faillock_interval
    - var_accounts_passwords_pam_faillock_unlock_time=never
    - accounts_passwords_pam_faillock_unlock_time
    - dconf_gnome_banner_enabled
    - login_banner_text=usgcb_default
    - dconf_gnome_login_banner_text
    - disable_users_coredumps
    - var_accounts_max_concurrent_login_sessions=10
    - accounts_max_concurrent_login_sessions
    - securetty_root_login_console_only
    - var_password_pam_unix_remember=5
    - accounts_password_pam_unix_remember

    # Password
    - var_accounts_password_minlen_login_defs=12
    - accounts_password_minlen_login_defs
    - var_password_pam_minlen=12
    - accounts_password_pam_minlen
    - var_password_pam_ocredit=1
    - accounts_password_pam_ocredit
    - var_password_pam_dcredit=1
    - accounts_password_pam_dcredit
    - var_password_pam_ucredit=1
    - accounts_password_pam_ucredit
    - var_password_pam_lcredit=1
    - accounts_password_pam_lcredit
    - var_password_pam_difok=4
    - accounts_password_pam_difok
    - var_password_pam_maxrepeat=3
    - accounts_password_pam_maxrepeat
    - var_password_pam_maxclassrepeat=4
    - accounts_password_pam_maxclassrepeat

    # umask
    - accounts_umask_etc_profile
    - accounts_umask_etc_bashrc
    - accounts_umask_etc_csh_cshrc

    # Console Screen Lock
    - package_screen_installed

    # Remote session timeout
    - sshd_idle_timeout_value=10_minutes
    - sshd_set_idle_timeout

    ### General Config

    # Software update
    - ensure_redhat_gpgkey_installed
    - ensure_gpgcheck_globally_activated
    - ensure_gpgcheck_local_packages
    - ensure_gpgcheck_never_disabled
