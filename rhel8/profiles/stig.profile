documentation_complete: true

metadata:
    version: V1R1
    SMEs:
        - carlosmmatos

reference: https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: 'DISA STIG for Red Hat Enterprise Linux 8'

description: |-
    This profile contains configuration checks that align to the
    DISA STIG for Red Hat Enterprise Linux 8.

    In addition to being applicable to Red Hat Enterprise Linux 8, DISA recognizes this
    configuration baseline as applicable to the operating system tier of
    Red Hat technologies that are based on Red Hat Enterprise Linux 8, such as:

    - Red Hat Enterprise Linux Server
    - Red Hat Enterprise Linux Workstation and Desktop
    - Red Hat Enterprise Linux for HPC
    - Red Hat Storage
    - Red Hat Containers with a Red Hat Enterprise Linux 8 image

selections:
    # variables
    - var_rekey_limit_size=1G
    - var_rekey_limit_time=1hour
    - var_accounts_user_umask=077
    - var_password_pam_difok=8
    - var_password_pam_maxrepeat=3
    - var_sshd_disable_compression=no
    - var_password_pam_maxclassrepeat=4
    - var_password_pam_minclass=4
    - var_accounts_minimum_age_login_defs=1
    - var_accounts_max_concurrent_login_sessions=10
    - var_password_pam_unix_remember=5
    - var_selinux_state=enforcing
    - var_selinux_policy_name=targeted
    - var_accounts_password_minlen_login_defs=15
    - var_password_pam_minlen=15
    - var_password_pam_ocredit=1
    - var_password_pam_dcredit=1
    - var_password_pam_ucredit=1
    - var_password_pam_lcredit=1
    - var_password_pam_retry=3
    - var_password_pam_minlen=15
    - sshd_idle_timeout_value=10_minutes
    - var_accounts_passwords_pam_faillock_deny=3
    - var_accounts_passwords_pam_faillock_fail_interval=900
    - var_accounts_passwords_pam_faillock_unlock_time=never
    - var_ssh_client_rekey_limit_size=1G
    - var_ssh_client_rekey_limit_time=1hour
    - var_accounts_fail_delay=4
    - var_account_disable_post_pw_expiration=35
    - var_auditd_action_mail_acct=root
    - var_time_service_set_maxpoll=18_hours
    - var_password_hashing_algorithm=SHA512
    - var_accounts_maximum_age_login_defs=60
    - var_auditd_space_left=250MB
    - var_auditd_space_left_action=email
    - var_auditd_disk_error_action=halt
    - var_auditd_max_log_file_action=syslog
    - var_auditd_disk_full_action=halt

    ### Enable / Configure FIPS
    - enable_fips_mode
    - var_system_crypto_policy=fips
    - configure_crypto_policy
    - configure_ssh_crypto_policy
    - configure_bind_crypto_policy
    - configure_openssl_crypto_policy
    - configure_libreswan_crypto_policy
    - configure_kerberos_crypto_policy
    - enable_dracut_fips_module

    # rules
    - installed_OS_is_vendor_supported
    - security_patches_up_to_date

    - sysctl_crypto_fips_enabled
    - encrypt_partitions
    - sshd_enable_warning_banner
    - dconf_gnome_banner_enabled
    - dconf_gnome_login_banner_text
    - banner_etc_issue
    - set_password_hashing_algorithm_logindefs
    - grub2_uefi_password
    - grub2_uefi_admin_username
    - grub2_password
    - grub2_admin_username
    - kerberos_disable_no_keytab
    - package_krb5-workstation_removed
    - selinux_state
    - package_policycoreutils_installed
    - sshd_set_idle_timeout
    - sshd_set_keepalive
    - sshd_use_strong_rng
    - file_permissions_binary_dirs
    - file_ownership_binary_dirs
    - file_permissions_library_dirs
    - file_ownership_library_dirs
    - ensure_gpgcheck_globally_activated
    - ensure_gpgcheck_local_packages
    - sysctl_kernel_kexec_load_disabled
    - sysctl_fs_protected_symlinks
    - sysctl_fs_protected_hardlinks
    - sysctl_kernel_dmesg_restrict
    - sysctl_kernel_perf_event_paranoid
    - sudo_remove_nopasswd
    - sudo_remove_no_authenticate
    - package_opensc_installed
    - grub2_page_poison_argument
    - grub2_vsyscall_argument
    - grub2_slub_debug_argument
    - sysctl_kernel_randomize_va_space
    - clean_components_post_updating
    - selinux_policytype
    - no_host_based_files
    - no_user_host_based_files
    - service_rngd_enabled
    - package_rng-tools_installed
    - file_permissions_sshd_pub_key
    - file_permissions_sshd_private_key
    - sshd_enable_strictmodes
    - sshd_disable_compression
    - sshd_disable_user_known_hosts
    - partition_for_var
    - partition_for_var_tmp
    - partition_for_var_log
    - partition_for_var_log_audit
    - partition_for_tmp
    - sshd_disable_root_login
    - service_auditd_enabled
    - service_rsyslog_enabled
    - mount_option_home_nosuid
    - mount_option_boot_nosuid
    - mount_option_nodev_nonroot_local_partitions
    - mount_option_nodev_removable_partitions
    - mount_option_noexec_removable_partitions
    - mount_option_nosuid_removable_partitions
    - mount_option_noexec_remote_filesystems
    - mount_option_nodev_remote_filesystems
    - mount_option_nosuid_remote_filesystems
    - service_kdump_disabled
    - sysctl_kernel_core_pattern
    - service_systemd-coredump_disabled
    - disable_users_coredumps
    - coredump_disable_storage
    - coredump_disable_backtraces
    - accounts_user_home_paths_only
    - accounts_user_interactive_home_directory_defined
    - file_permissions_home_directories
    - file_groupownership_home_directories
    - accounts_user_interactive_home_directory_exists
    - accounts_have_homedir_login_defs
    - file_permission_user_init_files
    - no_files_unowned_by_user
    - file_permissions_ungroupowned
    - partition_for_home
    - gnome_gdm_disable_automatic_login
    - sshd_do_not_permit_user_env
    - account_temp_expire_date
    - accounts_passwords_pam_faillock_deny
    - accounts_passwords_pam_faillock_interval
    - accounts_passwords_pam_faillock_unlock_time
    - accounts_passwords_pam_faillock_deny_root
    - accounts_max_concurrent_login_sessions
    - dconf_gnome_screensaver_lock_enabled
    - configure_bashrc_exec_tmux
    - no_tmux_in_shells
    - dconf_gnome_screensaver_idle_delay
    - configure_tmux_lock_after_time
    - accounts_password_pam_ucredit
    - accounts_password_pam_lcredit
    - accounts_password_pam_dcredit
    - accounts_password_pam_maxclassrepeat
    - accounts_password_pam_maxrepeat
    - accounts_password_pam_minclass
    - accounts_password_pam_difok
    - accounts_password_set_min_life_existing
    - accounts_minimum_age_login_defs
    - accounts_maximum_age_login_defs
    - accounts_password_set_max_life_existing
    - accounts_password_pam_unix_remember
    - accounts_password_pam_minlen
    - accounts_password_minlen_login_defs
    - account_disable_post_pw_expiration
    - accounts_password_pam_ocredit
    - sssd_offline_cred_expiration
    - accounts_logon_fail_delay
    - display_login_attempts
    - sshd_print_last_log
    - accounts_umask_etc_login_defs
    - accounts_umask_interactive_users
    - accounts_umask_etc_bashrc
    - rsyslog_cron_logging
    - auditd_data_retention_action_mail_acct
    - postfix_client_configure_mail_alias
    - auditd_data_disk_error_action
    - auditd_data_retention_max_log_file_action
    - auditd_data_disk_full_action
    - auditd_local_events
    - auditd_name_format
    - auditd_log_format
    - file_permissions_var_log_audit
    - directory_permissions_var_log_audit
    # - audit_rules_immutable
    # - audit_immutable_login_uids
    # - audit_rules_usergroup_modification_shadow
    # - audit_rules_usergroup_modification_opasswd
    # - audit_rules_usergroup_modification_passwd
    # - audit_rules_usergroup_modification_gshadow
    # - audit_rules_usergroup_modification_group
    # - audit_rules_login_events_lastlog
    - grub2_audit_argument
    - grub2_audit_backlog_limit_argument
    - configure_usbguard_auditbackend
    - package_rsyslog_installed
    - package_rsyslog-gnutls_installed
    - rsyslog_remote_loghost
    # this rule expects configuration in MB instead percentage as how STIG demands
    # - auditd_data_retention_space_left
    - auditd_data_retention_space_left_action
    # remediation fails because default configuration file contains pool instead of server keyword
    - chronyd_or_ntpd_set_maxpoll
    - chronyd_client_only
    - chronyd_no_chronyc_network
    - package_telnet-server_removed
    - package_abrt_removed
    - package_abrt-addon-ccpp_removed
    - package_abrt-addon-kerneloops_removed
    - package_abrt-addon-python_removed
    - package_abrt-cli_removed
    - package_abrt-plugin-logger_removed
    - package_abrt-plugin-rhtsupport_removed
    - package_abrt-plugin-sosreport_removed
    - package_sendmail_removed
    # - package_gssproxy_removed
    - grub2_pti_argument
    - package_rsh-server_removed
    - kernel_module_atm_disabled
    - kernel_module_can_disabled
    - kernel_module_sctp_disabled
    - kernel_module_tipc_disabled
    - kernel_module_cramfs_disabled
    - kernel_module_firewire-core_disabled
    - configure_firewalld_ports
    - service_autofs_disabled
    - kernel_module_usb-storage_disabled
    - service_firewalld_enabled
    - package_firewalld_installed
    - wireless_disable_interfaces
    - kernel_module_bluetooth_disabled
    - mount_option_dev_shm_nodev
    - mount_option_dev_shm_nosuid
    - mount_option_dev_shm_noexec
    - mount_option_tmp_nodev
    - mount_option_tmp_nosuid
    - mount_option_tmp_noexec
    - mount_option_var_log_nodev
    - mount_option_var_log_nosuid
    - mount_option_var_log_noexec
    - mount_option_var_log_audit_nodev
    - mount_option_var_log_audit_nosuid
    - mount_option_var_log_audit_noexec
    - mount_option_var_tmp_nodev
    - mount_option_var_tmp_nosuid
    - mount_option_var_tmp_noexec
    - package_openssh-server_installed
    - service_sshd_enabled
    - sshd_rekey_limit
    - ssh_client_rekey_limit
    - disable_ctrlaltdel_reboot
    - dconf_gnome_disable_ctrlaltdel_reboot
    - disable_ctrlaltdel_burstaction
    - service_debug-shell_disabled
    - package_tftp-server_removed
    - accounts_no_uid_except_zero
    - sysctl_net_ipv4_conf_default_accept_redirects
    - sysctl_net_ipv6_conf_default_accept_redirects
    - sysctl_net_ipv4_conf_all_send_redirects
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts
    - sysctl_net_ipv4_conf_all_accept_source_route
    - sysctl_net_ipv6_conf_all_accept_source_route
    - sysctl_net_ipv4_conf_default_accept_source_route
    - sysctl_net_ipv6_conf_default_accept_source_route
    - sysctl_net_ipv4_ip_forward
    - sysctl_net_ipv6_conf_all_accept_ra
    - sysctl_net_ipv6_conf_default_accept_ra
    - sysctl_net_ipv4_conf_default_send_redirects
    - sysctl_net_ipv4_conf_all_accept_redirects
    - sysctl_net_ipv6_conf_all_accept_redirects
    - sysctl_kernel_unprivileged_bpf_disabled
    - sysctl_kernel_yama_ptrace_scope
    - sysctl_kernel_kptr_restrict
    - sysctl_user_max_user_namespaces
    - sysctl_net_ipv4_conf_all_rp_filter
    # /etc/postfix/main.cf does not exist on default installation resulting in error during remediation
    # there needs to be a new platform check to identify when postfix is installed or not
    # - postfix_prevent_unrestricted_relay
    - aide_verify_ext_attributes
    - aide_verify_acls
    # - package_xorg-x11-server-common_removed
    - sshd_disable_x11_forwarding
    - sshd_x11_use_localhost
    - tftpd_uses_secure_mode
    - package_vsftpd_removed
    - package_iprutils_removed
    - package_tuned_removed
    - require_emergency_target_auth
    - require_singleuser_auth
    - set_password_hashing_algorithm_systemauth
    - dir_perms_world_writable_sticky_bits
    - package_aide_installed
    - aide_scan_notification
    - install_smartcard_packages
    - sshd_disable_kerb_auth
    - sshd_disable_gssapi_auth
    - accounts_user_dot_no_world_writable_programs
    - network_configure_name_resolution
    - dir_perms_world_writable_root_owned
    - package_tmux_installed
    - configure_tmux_lock_command
    - accounts_password_pam_retry
    - sssd_enable_smartcards
    - no_empty_passwords
    - sshd_disable_empty_passwords
    - file_ownership_var_log_audit
    # - audit_rules_sysadmin_actions
    - package_audit_installed
    - service_auditd_enabled
    - sshd_allow_only_protocol2
    - package_fapolicyd_installed
    - service_fapolicyd_enabled
    - package_usbguard_installed
    - service_usbguard_enabled
    - network_sniffer_disabled
