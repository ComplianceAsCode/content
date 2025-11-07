documentation_complete: true

metadata:
    version: 4.2.1

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
    - ospp:all

    # special unused variables since we can't unselect variables. So we select the default value again
    - 'var_logind_session_timeout=5_minutes'

    # readd rules that are not present in the OSPP control file
    - openssl_use_strong_entropy
    - coredump_disable_backtraces
    - configure_bashrc_exec_tmux
    - dnf-automatic_security_updates_only
    - kernel_module_atm_disabled
    - sysctl_net_ipv4_icmp_ignore_bogus_error_responses
    - mount_option_tmp_nodev
    - mount_option_var_log_nosuid
    - package_abrt-plugin-sosreport_removed
    - sysctl_net_ipv6_conf_default_accept_redirects
    - accounts_umask_etc_bashrc
    - sysctl_net_ipv4_conf_all_accept_source_route
    - mount_option_var_tmp_nosuid
    - package_abrt-cli_removed
    - securetty_root_login_console_only
    - sshd_use_strong_rng
    - sysctl_fs_protected_hardlinks
    - sysctl_net_ipv4_ip_forward
    - grub2_pti_argument
    - mount_option_nodev_nonroot_local_partitions
    - partition_for_var_tmp
    - configure_bind_crypto_policy
    - sshd_enable_strictmodes
    - grub2_slub_debug_argument
    - sshd_idle_timeout_value=14_minutes
    - sysctl_user_max_user_namespaces.role=unscored
    - sysctl_net_ipv4_conf_all_accept_redirects
    - accounts_password_pam_maxclassrepeat
    - grub2_page_poison_argument
    - sysctl_net_ipv6_conf_default_accept_ra
    - mount_option_boot_nosuid
    - enable_authselect
    - sysctl_net_ipv4_conf_default_send_redirects
    - package_policycoreutils_installed
    - mount_option_var_tmp_noexec
    - package_libreport-plugin-rhtsupport_removed
    - grub2_uefi_password
    - mount_option_dev_shm_nosuid
    - var_password_pam_maxclassrepeat=4
    - mount_option_tmp_noexec
    - package_rsyslog_installed
    - accounts_password_pam_unix_remember
    - sysctl_net_ipv4_tcp_syncookies
    - package_iprutils_removed
    - configure_tmux_lock_after_time
    - package_libreport-plugin-logger_removed
    - disable_users_coredumps
    - sysctl_net_ipv4_conf_default_accept_redirects
    - var_password_pam_unix_remember=5
    - kerberos_disable_no_keytab
    - package_abrt-addon-ccpp_removed
    - accounts_umask_etc_csh_cshrc
    - mount_option_home_nodev
    - sshd_set_keepalive_0
    - accounts_max_concurrent_login_sessions
    - var_authselect_profile=minimal
    - sysctl_user_max_user_namespaces.severity=info
    - configure_libreswan_crypto_policy
    - var_accounts_user_umask=027
    - sysctl_net_ipv4_conf_default_rp_filter
    - sysctl_net_ipv4_conf_all_secure_redirects
    - package_tmux_installed
    - accounts_password_pam_maxrepeat
    - partition_for_var
    - grub2_vsyscall_argument.role=unscored
    - mount_option_boot_nodev
    - var_accounts_max_concurrent_login_sessions=10
    - grub2_vsyscall_argument.severity=info
    - sshd_set_idle_timeout
    - accounts_password_pam_difok
    - sysctl_net_ipv4_conf_all_log_martians
    - partition_for_var_log
    - package_abrt_removed
    - coredump_disable_storage
    - configure_tmux_lock_command
    - var_password_pam_difok=4
    - sysctl_net_ipv4_conf_all_rp_filter
    - mount_option_var_nodev
    - kernel_module_firewire-core_disabled
    - sysctl_net_ipv6_conf_default_accept_source_route
    - sysctl_net_core_bpf_jit_harden
    - sysctl_fs_protected_symlinks
    - package_sendmail_removed
    - package_krb5-workstation_removed
    - var_password_pam_maxrepeat=3
    - mount_option_tmp_nosuid
    - partition_for_home
    - package_python3-abrt-addon_removed
    - sysctl_net_ipv4_conf_default_secure_redirects
    - sysctl_kernel_unprivileged_bpf_disabled
    - configure_kerberos_crypto_policy
    - auditd_write_logs
    - accounts_umask_etc_profile
    - no_tmux_in_shells
    - kernel_module_cramfs_disabled
    - mount_option_home_nosuid
    - auditd_local_events
    - package_aide_installed
    - sysctl_net_ipv6_conf_all_accept_ra
    - sysctl_net_ipv6_conf_all_accept_source_route
    - sysctl_net_ipv6_conf_all_accept_redirects
    - sysctl_net_ipv4_conf_default_accept_source_route
    - mount_option_var_tmp_nodev
    - mount_option_var_log_nodev
    - sysctl_net_ipv4_conf_all_send_redirects
    - grub2_kernel_trust_cpu_rng
    - sysctl_net_ipv4_conf_default_log_martians
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts
    - package_gssproxy_removed
    - mount_option_dev_shm_noexec
    - package_abrt-addon-kerneloops_removed
    - ssh_client_use_strong_rng_csh
    - chronyd_no_chronyc_network
    - mount_option_var_log_noexec
    - sysctl_kernel_core_pattern
    - mount_option_dev_shm_nodev
    - ssh_client_use_strong_rng_sh
    - package_nfs-utils_removed
    - package_policycoreutils-python-utils_installed
    - ensure_oracle_gpgkey_installed


    # remove extranous rules coming from the OSPP control File
    - '!audit_access_failed_ppc64le'
    - '!audit_access_success_ppc64le.role=unscored'
    - '!audit_ospp_general_aarch64'
    - '!sysctl_kernel_core_pattern_empty_string'
    - '!audit_perm_change_failed_ppc64le'
    - '!sshd_use_directory_configuration'
    - '!zipl_init_on_alloc_argument'
    - '!audit_access_success_ppc64le.severity=info'
    - '!audit_owner_change_failed_aarch64'
    - '!audit_access_success_aarch64.role=unscored'
    - '!grub2_systemd_debug-shell_argument_absent'
    - '!sysctl_kernel_core_uses_pid'
    - '!grub2_init_on_alloc_argument'
    - '!audit_perm_change_success_ppc64le'
    - '!audit_modify_failed_aarch64'
    - '!audit_modify_success_aarch64'
    - '!audit_delete_failed_aarch64'
    - '!audit_perm_change_success_aarch64'
    - '!sysctl_kernel_unprivileged_bpf_disabled_accept_default'
    - '!grub2_password'
    - '!audit_access_success.severity=info'
    - '!audit_delete_success_ppc64le'
    - '!audit_create_success_aarch64'
    - '!audit_create_success_ppc64le'
    - '!audit_access_success.role=unscored'
    - '!audit_owner_change_success_ppc64le'
    - '!audit_access_success_aarch64'
    - '!audit_delete_failed_ppc64le'
    - '!audit_perm_change_failed_aarch64'
    - '!grub2_page_alloc_shuffle_argument'
    - '!audit_delete_success_aarch64'
    - '!audit_access_success_aarch64.severity=info'
    - '!audit_modify_success_ppc64le'
    - '!audit_owner_change_failed_ppc64le'
    - '!audit_owner_change_success_aarch64'
    - '!audit_access_success_ppc64le'
    - '!audit_create_failed_ppc64le'
    - '!audit_ospp_general_ppc64le'
    - '!logind_session_timeout'
    - '!audit_create_failed_aarch64'
    - '!zipl_page_alloc_shuffle_argument'
    - '!audit_module_load_ppc64le'
    - '!audit_access_failed_aarch64'
    - '!zipl_systemd_debug-shell_argument_absent'
    - '!audit_modify_failed_ppc64le'

    # Following rules are not applicable to OL
    - '!ensure_redhat_gpgkey_installed'
    - '!package_dnf-plugin-subscription-manager_installed'
    - '!package_subscription-manager_installed'
    - '!zipl_audit_argument'
    - '!zipl_audit_backlog_limit_argument'
    - '!zipl_bls_entries_only'
    - '!zipl_bootmap_is_up_to_date'
