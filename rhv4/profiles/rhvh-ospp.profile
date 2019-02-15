documentation_complete: true

title: 'VPP - Protection Profile for Virtualization v. 1.0'

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
    - NIST 800-53 control selections for MODERATE impact systems (NIST 800-53)
    - U.S. Government Configuration Baseline (USGCB)
    - NIAP Protection Profile for Virtualization v1.0 (VPP v1.0)

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
    # AC-2
    - service_auditd_enabled

    # AC-3
    - selinux_state
    - grub2_enable_selinux
    - selinux_policytype
    - grub2_password
    - grub2_uefi_password
    - grub2_disable_interactive_boot
    - disable_host_auth

    # AC-7(a)
    - accounts_passwords_pam_faillock_deny
    ######### NEED VARIABLE var_accounts_passwords_pam_faillock_deny
    - accounts_passwords_pam_faillock_interval
    ### NEED var_accounts_passwords_pam_faillock_fail_interval
    - accounts_passwords_pam_faillock_deny_root

    # AC-7(b)
    - accounts_passwords_pam_faillock_unlock_time
    ##### NEED var_accounts_passwords_pam_faillock_unlock_time

    # AC-8
    - banner_etc_issue+

    # AC-17(a)
    - file_permissions_sshd_private_key
    - file_permissions_sshd_pub_key
    - disable_host_auth
    - sshd_allow_only_protocol2
    - sshd_disable_compression
    - sshd_disable_gssapi_auth
    - sshd_disable_kerb_auth
    - sshd_disable_rhosts
    - sshd_disable_rhosts_rsa
    - sshd_disable_root_login
    - sshd_disable_user_known_hosts
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





    # SI-2, RA-1
    - security_patches_up_to_date
    - clean_components_post_updating
    - installed_OS_is_vendor_supported

    # SI-3
    - install_antivirus

    # SC-39
    - sysctl_kernel_exec_shield

    # SC-22
    - network_configure_name_resolution

    # SC-13
    - sebool_fips_mode
    - encrypt_partitions
    - sshd_use_approved_macs

    # SC-7
    - install_hids
    - sysctl_net_ipv4_conf_default_send_redirects
    - sysctl_net_ipv4_conf_default_accept_redirects
    - sysctl_net_ipv4_conf_default_accept_source_route
    - sysctl_net_ipv4_conf_default_secure_redirects
    - sysctl_net_ipv4_conf_all_rp_filter
    - sysctl_net_ipv4_conf_default_rp_filter

    # SC-5
    - disable_users_coredumps
    - sysctl_net_ipv4_ip_forward
    - sysctl_net_ipv4_conf_default_send_redirects
    - sysctl_net_ipv4_conf_default_accept_redirects
    - sysctl_net_ipv4_conf_all_accept_redirects
    - sysctl_net_ipv4_conf_default_accept_source_route
    - sysctl_net_ipv4_conf_default_secure_redirects
    - sysctl_net_ipv4_conf_all_rp_filter
    - sysctl_net_ipv4_tcp_syncookies
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts
    - sysctl_net_ipv4_conf_all_secure_redirects
    - sysctl_net_ipv4_icmp_ignore_bogus_error_responses
    - sysctl_net_ipv4_conf_default_rp_filter
    - sysctl_net_ipv4_conf_default_log_martians
    - sysctl_net_ipv4_conf_all_accept_source_route
    - sysctl_net_ipv4_conf_all_log_martians
    - sysctl_net_ipv6_conf_all_forwarding

    # MP-2
    - mount_option_tmp_nodev
    - mount_option_dev_shm_nosuid
    - mount_option_nosuid_removable_partitions
    - mount_option_tmp_noexec
    - mount_option_dev_shm_noexec
    - mount_option_dev_shm_nodev
    - mount_option_noexec_removable_partitions
    - mount_option_tmp_nosuid
    - mount_option_nodev_removable_partitions
    - mount_option_home_nosuid
    - mount_option_nodev_remote_filesystems

    # MA-4, MA-2
    - package_libreswan_installed
    - audit_rules_file_deletion_events_rmdir
    - audit_rules_file_deletion_events_renameat
    - audit_rules_file_deletion_events_unlinkat
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_unlink

    # MA-1
    - ensure_gpgcheck_never_disabled
    - ensure_redhat_gpgkey_installed
    - ensure_gpgcheck_globally_activated
    - security_patches_up_to_date
    - network_sniffer_disabled

    # IR-5
    - audit_rules_unsuccessful_file_modification_rename
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_rule_order
    - audit_rules_unsuccessful_file_modification_ftruncate
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_creat
    - audit_rules_unsuccessful_file_modification_openat_o_trunc_write
    - audit_rules_unsuccessful_file_modification_open_o_trunc_write
    - audit_rules_unsuccessful_file_modification
    - audit_rules_unsuccessful_file_modification_unlinkat
    - audit_rules_unsuccessful_file_modification_openat_o_creat
    - audit_rules_unsuccessful_file_modification_openat_rule_order
    - audit_rules_unsuccessful_file_modification_openat
    - audit_rules_unsuccessful_file_modification_open_rule_order
    - audit_rules_unsuccessful_file_modification_open
    - audit_rules_unsuccessful_file_modification_open_by_handle_at
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_trunc_write
    - audit_rules_unsuccessful_file_modification_truncate
    - audit_rules_unsuccessful_file_modification_renameat
    - audit_rules_unsuccessful_file_modification_creat
    - audit_rules_unsuccessful_file_modification_open_o_creat
    - audit_rules_unsuccessful_file_modification_unlink
    - audit_rules_mac_modification
    - audit_rules_usergroup_modification_passwd
    - audit_rules_networkconfig_modification
    - file_permissions_var_log_audit
    - audit_rules_file_deletion_events_rmdir
    - audit_rules_file_deletion_events_renameat
    - audit_rules_file_deletion_events_unlinkat
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_unlink
    - audit_rules_time_adjtimex
    - audit_rules_time_settimeofday
    - audit_rules_time_watch_localtime
    - audit_rules_time_clock_settime
    - audit_rules_time_stime
    - audit_rules_sysadmin_actions
    - audit_rules_media_export
    - audit_rules_privileged_commands
    - audit_rules_session_events
    - directory_permissions_var_log_audit
    - audit_rules_login_events_faillock
    - audit_rules_login_events_tallylog
    - audit_rules_login_events_lastlog
    - audit_rules_immutable
    - file_ownership_var_log_audit
    - audit_rules_kernel_module_loading_delete
    - audit_rules_kernel_module_loading_finit
    - audit_rules_kernel_module_loading_modprobe
    - audit_rules_kernel_module_loading_init
    - audit_rules_kernel_module_loading_rmmod
    - audit_rules_kernel_module_loading_insmod
    - audit_rules_kernel_module_loading
    - audit_rules_usergroup_modification_shadow
    - audit_rules_usergroup_modification_group
    - audit_rules_dac_modification_lchown
    - audit_rules_dac_modification_fchownat
    - audit_rules_dac_modification_setxattr
    - audit_rules_dac_modification_chmod
    - audit_rules_dac_modification_removexattr
    - audit_rules_dac_modification_lsetxattr
    - audit_rules_dac_modification_chown
    - audit_rules_dac_modification_fremovexattr
    - audit_rules_dac_modification_lremovexattr
    - audit_rules_dac_modification_fchmod
    - audit_rules_dac_modification_fchmodat
    - audit_rules_dac_modification_fsetxattr
    - audit_rules_dac_modification_fchown
    - audit_rules_usergroup_modification_opasswd
    - audit_rules_usergroup_modification_gshadow
    - grub2_audit_argument
    - auditd_data_retention_max_log_file
    - auditd_audispd_syslog_plugin_activated
    - auditd_data_retention_max_log_file_action
    - auditd_data_retention_space_left_action
    - auditd_data_retention_admin_space_left_action
    - auditd_data_retention_space_left
    - auditd_data_disk_error_action
    - auditd_data_disk_full_action
    - auditd_data_retention_action_mail_acct
    - auditd_data_retention_num_logs

    # IA-7
    - set_password_hashing_algorithm_logindefs
    - set_password_hashing_algorithm_systemauth
    - set_password_hashing_algorithm_libuserconf
    - sshd_use_approved_macs
    - sshd_use_approved_ciphers

    # IA-5(1)
    - accounts_password_pam_unix_remember
    - set_password_hashing_algorithm_logindefs
    - set_password_hashing_algorithm_systemauth
    - set_password_hashing_algorithm_libuserconf
    - accounts_password_pam_ocredit
    - accounts_password_pam_lcredit
    - accounts_password_pam_difok
    - accounts_password_pam_dcredit
    - accounts_password_pam_minlen
    - accounts_password_pam_ucredit
    - accounts_password_minlen_login_defs
    - accounts_maximum_age_login_defs
    - accounts_minimum_age_login_defs
    - no_empty_passwords
    - sshd_allow_only_protocol2
    - sshd_use_approved_ciphers
    - service_telnet_disabled
    - service_rlogin_disabled
    - service_rsh_disabled

    # IA-4
    - account_disable_post_pw_expiration
    - accounts_no_uid_except_zero

    # IA-2(1)
    - grub2_password
    - require_singleuser_auth
    - accounts_no_uid_except_zero
    - sshd_disable_root_login
    - no_direct_root_logins

    # CM-7
    - package_httpd_removed
    - service_httpd_disabled
    - package_ypserv_removed
    - service_ypbind_disabled
    - service_tftp_disabled
    - package_tftp-server_removed
    - tftpd_uses_secure_mode
    - service_xinetd_disabled
    - package_xinetd_removed
    - package_telnet-server_removed
    - service_rexec_disabled
    - service_rlogin_disabled
    - no_rsh_trust_files
    - package_rsh-server_removed
    - sssd_ldap_start_tls

    # CM-6
    - no_files_unowned_by_user
    - bios_enable_execution_restrictions
    - disable_prelink
    - aide_periodic_cron_checking
    - aide_build_database
    - package_aide_installed
    - rpm_verify_permissions
    - rpm_verify_ownership
    - rpm_verify_hashes
    - rsyslog_nolisten
    - sysctl_net_ipv4_conf_all_accept_redirects
    - network_disable_ddns_interfaces
    - service_firewalld_enabled
    - set_firewalld_default_zone
    - accounts_password_pam_retry
    - accounts_logon_fail_delay
    - root_path_no_dot
    - accounts_root_path_dirs_no_write
    - accounts_umask_etc_login_defs
    - package_vsftpd_removed
    - sshd_do_not_permit_user_env
    - disable_host_auth
    - sshd_disable_rhosts
    - sshd_disable_empty_passwords
    - sshd_disable_rhosts_rsa
    - sshd_use_approved_ciphers
    - sshd_disable_compression
    - sshd_disable_user_known_hosts
    - sshd_disable_gssapi_auth
    - sshd_disable_kerb_auth
    - package_tftp-server_removed

    # CM-2
    - sshd_enable_x11_forwarding

    # AU-12
    - service_rsyslog_enabled
    - rsyslog_accepting_remote_messages service_syslogng_enabled
    - audit_rules_unsuccessful_file_modification_rename
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_rule_order
    - audit_rules_unsuccessful_file_modification_ftruncate
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_creat
    - audit_rules_unsuccessful_file_modification_openat_o_trunc_write 
    - audit_rules_unsuccessful_file_modification_open_o_trunc_write
    - audit_rules_unsuccessful_file_modification
    - audit_rules_unsuccessful_file_modification_unlinkat
    - audit_rules_unsuccessful_file_modification_openat_o_creat
    - audit_rules_unsuccessful_file_modification_openat_rule_order
    - audit_rules_unsuccessful_file_modification_openat
    - audit_rules_unsuccessful_file_modification_open_rule_order
    - audit_rules_unsuccessful_file_modification_open
    - audit_rules_unsuccessful_file_modification_open_by_handle_at
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_trunc_write
    - audit_rules_unsuccessful_file_modification_truncate
    - audit_rules_unsuccessful_file_modification_renameat
    - audit_rules_unsuccessful_file_modification_creat
    - audit_rules_unsuccessful_file_modification_open_o_creat
    - audit_rules_unsuccessful_file_modification_unlink
    - audit_rules_mac_modification
    - audit_rules_usergroup_modification
    - audit_rules_usergroup_modification_passwd
    - audit_rules_networkconfig_modification
    - audit_rules_file_deletion_events_rmdir
    - audit_rules_file_deletion_events
    - audit_rules_file_deletion_events_renameat
    - audit_rules_file_deletion_events_unlinkat
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_unlink 
    - audit_rules_time_adjtimex
    - audit_rules_time_settimeofday
    - audit_rules_time_watch_localtime
    - audit_time_rules audit_rules_time_clock_settime
    - audit_time_rules audit_rules_time_stime
    - audit_rules_sysadmin_actions
    - audit_rules_execution_setsebool
    - audit_rules_execution_semanage
    - audit_rules_execution_restorecon
    - audit_rules_execution_chcon
    - audit_rules_media_export
    - audit_rules_privileged_commands_postqueue 
    - audit_rules_privileged_commands_sudoedit
    - audit_rules_privileged_commands_postdrop
    - audit_rules_privileged_commands_su
    - audit_rules_privileged_commands_gpasswd
    - audit_rules_privileged_commands_umount
    - audit_rules_privileged_commands_crontab
    - audit_rules_privileged_commands_sudo
    - audit_rules_privileged_commands_ssh_keysign
    - audit_rules_privileged_commands
    - audit_rules_privileged_commands_userhelper
    - audit_rules_privileged_commands_passwd
    - audit_rules_privileged_commands_chsh
    - audit_rules_privileged_commands_unix_chkpwd
    - audit_rules_privileged_commands_pt_chown
    - audit_rules_privileged_commands_pam_timestamp_check
    - audit_rules_privileged_commands_newgrp
    - audit_rules_privileged_commands_chage
    - audit_rules_session_events
    - audit_rules_login_events_faillock
    - audit_rules_login_events_tallylog
    - audit_rules_login_events_lastlog
    - audit_rules_kernel_module_loading_delete
    - audit_rules_kernel_module_loading_finit
    - audit_rules_kernel_module_loading_modprobe
    - audit_rules_kernel_module_loading_init
    - audit_rules_kernel_module_loading_rmmod
    - audit_rules_kernel_module_loading_insmod
    - audit_rules_usergroup_modification_shadow
    - audit_rules_usergroup_modification_group
    - audit_dac_actions audit_rules_dac_modification_lchown
    - audit_dac_actions audit_rules_dac_modification_fchownat
    - audit_dac_actions audit_rules_dac_modification_setxattr
    - audit_dac_actions audit_rules_dac_modification_chmod
    - audit_dac_actions audit_rules_dac_modification_removexattr
    - audit_dac_actions audit_rules_dac_modification_lsetxattr
    - audit_dac_actions audit_rules_dac_modification_chown
    - audit_dac_actions audit_rules_dac_modification_fremovexattr
    - audit_dac_actions audit_rules_dac_modification_lremovexattr
    - audit_dac_actions audit_rules_dac_modification_fchmod
    - audit_dac_actions audit_rules_dac_modification_fchmodat
    - audit_dac_actions audit_rules_dac_modification_fsetxattr
    - audit_dac_actions audit_rules_dac_modification_fchown
    - audit_rules_usergroup_modification_opasswd
    - audit_rules_usergroup_modification_gshadow

    - auditd_data_retention_flush

    # AU-11
    - auditd_data_retention_max_log_file
    - auditd_data_retention_max_log_file_action
    - auditd_data_retention_num_logs

    # AU-9
    - selinux_all_devicefiles_labeled
    - selinux_state
    - service_restorecond_enabled
    - grub2_enable_selinux
    - selinux_policytype
    - selinux_confinement_of_daemons
    - partition_for_var_log_audit
    - partition_for_var_log

    - ensure_logrotate_activated
    - package_rsyslog_installed
    - rsyslog_accept_remote_messages_tcp
    - rsyslog_nolisten
    - rsyslog_remote_loghost



    - directory_permissions_var_log_audit
    - auditd_data_retention_flush

    # AU-8
    - service_chronyd_or_ntpd_enabled
    - chronyd_or_ntpd_specify_multiple_servers
    - chronyd_or_ntpd_set_maxpoll
    - chronyd_or_ntpd_specify_remote_server

    # AU-6
    - audit_rules_privileged_commands




    - auditd_data_retention_space_left_action
    - auditd_data_retention_admin_space_left_action
    - auditd_data_disk_error_action
    - auditd_data_retention_space_left
    - auditd_data_disk_full_action
    - auditd_data_retention_action_mail_acct

    # AU-4
    - partition_for_var_log_audit
    - service_rsyslog_enabled
    - rsyslog_remote_loghost
    - auditd_data_retention_max_log_file_action
    - auditd_data_retention_space_left_action
    - auditd_data_retention_admin_space_left_action 
    - auditd_data_disk_error_action
    - auditd_data_retention_space_left
    - auditd_data_disk_full_action
    - auditd_data_retention_action_mail_acct

    # AU-3
    - rsyslog_remote_loghost
    - audit_rules_sysadmin_actions
    - audit_rules_media_export
    - audit_rules_privileged_commands_postqueue
    - audit_rules_privileged_commands_sudoedit
    - audit_rules_privileged_commands_postdrop
    - audit_rules_privileged_commands_su
    - audit_rules_privileged_commands_umount
    - audit_rules_privileged_commands_crontab
    - audit_rules_privileged_commands_sudo
    - audit_rules_privileged_commands_ssh_keysign
    - audit_rules_privileged_commands_userhelper
    - audit_rules_privileged_commands_passwd
    - audit_rules_privileged_commands_chsh
    - audit_rules_privileged_commands_unix_chkpwd
    - audit_rules_privileged_commands_pt_chown
    - audit_rules_privileged_commands_pam_timestamp_check
    - audit_rules_privileged_commands_newgrp
    - audit_rules_privileged_commands_chage
    - service_auditd_enabled
    - auditd_audispd_syslog_plugin_activated

    # AU-2
    - rsyslog_cron_logging
    - audit_rules_unsuccessful_file_modification_rename
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_rule_order
    - audit_rules_unsuccessful_file_modification_ftruncate
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_creat
    - audit_rules_unsuccessful_file_modification_openat_o_trunc_write
    - audit_rules_unsuccessful_file_modification_open_o_trunc_write
    - audit_rules_unsuccessful_file_modification_unlinkat
    - audit_rules_unsuccessful_file_modification_openat_o_creat
    - audit_rules_unsuccessful_file_modification_openat_rule_order
    - audit_rules_unsuccessful_file_modification_openat
    - audit_rules_unsuccessful_file_modification_open_rule_order
    - audit_rules_unsuccessful_file_modification_open
    - audit_rules_unsuccessful_file_modification_open_by_handle_at
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_trunc_write
    - audit_rules_unsuccessful_file_modification_truncate
    - audit_rules_unsuccessful_file_modification_renameat
    - audit_rules_unsuccessful_file_modification_creat
    - audit_rules_unsuccessful_file_modification_open_o_creat
    - audit_rules_unsuccessful_file_modification_unlink
    - audit_rules_mac_modification
    - audit_rules_usergroup_modification_passwd
    - audit_rules_networkconfig_modification
    - audit_rules_file_deletion_events_rmdir
    - audit_rules_file_deletion_events_renameat
    - audit_rules_file_deletion_events_unlinkat
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_unlink
    - audit_rules_time_adjtimex
    - audit_rules_time_settimeofday
    - audit_rules_time_watch_localtime
    - audit_rules_time_clock_settime
    - audit_rules_time_stime
    - audit_rules_sysadmin_actions
    - audit_rules_media_export
    - audit_rules_privileged_commands
    - audit_rules_session_events
    - audit_rules_immutable
    - audit_rules_kernel_module_loading_delete
    - audit_rules_kernel_module_loading_finit
    - audit_rules_kernel_module_loading_modprobe
    - audit_rules_kernel_module_loading_init
    - audit_rules_kernel_module_loading_rmmod
    - audit_rules_kernel_module_loading_insmod
    - audit_rules_usergroup_modification_shadow
    - audit_rules_usergroup_modification_group
    - audit_rules_dac_modification_lchown
    - audit_rules_dac_modification_fchownat
    - audit_rules_dac_modification_setxattr
    - audit_rules_dac_modification_chmod
    - audit_rules_dac_modification_removexattr
    - audit_rules_dac_modification_lsetxattr
    - audit_rules_dac_modification_chown
    - audit_rules_dac_modification_fremovexattr
    - audit_rules_dac_modification_lremovexattr
    - audit_rules_dac_modification_fchmod
    - audit_rules_dac_modification_fchmodat
    - audit_rules_dac_modification_fsetxattr
    - audit_rules_dac_modification_fchown
    - audit_rules_usergroup_modification_opasswd
    - audit_rules_usergroup_modification_gshadow
    - grub2_audit_argument

    # AU-1
    - audit_rules_unsuccessful_file_modification_rename
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_rule_order
    - audit_rules_unsuccessful_file_modification_ftruncate
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_creat
    - audit_rules_unsuccessful_file_modification_openat_o_trunc_write
    - audit_rules_unsuccessful_file_modification_open_o_trunc_write
    - audit_rules_unsuccessful_file_modification_unlinkat
    - audit_rules_unsuccessful_file_modification_openat_o_creat
    - audit_rules_unsuccessful_file_modification_openat_rule_order
    - audit_rules_unsuccessful_file_modification_openat
    - audit_rules_unsuccessful_file_modification_open_rule_order
    - audit_rules_unsuccessful_file_modification_open
    - audit_rules_unsuccessful_file_modification_open_by_handle_at
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_trunc_write
    - audit_rules_unsuccessful_file_modification_truncate
    - audit_rules_unsuccessful_file_modification_renameat
    - audit_rules_unsuccessful_file_modification_creat
    - audit_rules_unsuccessful_file_modification_open_o_creat
    - audit_rules_unsuccessful_file_modification_unlink
    - audit_rules_mac_modification
    - audit_rules_usergroup_modification_passwd
    - audit_rules_networkconfig_modification
    - file_permissions_var_log_audit
    - audit_rules_file_deletion_events_rmdir
    - audit_rules_file_deletion_events_renameat
    - audit_rules_file_deletion_events_unlinkat
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_unlink
    - audit_rules_time_adjtimex
    - audit_rules_time_settimeofday
    - audit_rules_time_watch_localtime
    - audit_rules_time_clock_settime
    - audit_rules_time_stime
    - audit_rules_sysadmin_actions
    - audit_rules_media_export
    - audit_rules_privileged_commands
    - audit_rules_session_events
    - directory_permissions_var_log_audit
    - audit_rules_login_events_faillock
    - audit_rules_login_events_tallylog
    - audit_rules_login_events_lastlog
    - audit_rules_immutable
    - file_ownership_var_log_audit
    - audit_rules_kernel_module_loading_delete
    - audit_rules_kernel_module_loading_finit
    - audit_rules_kernel_module_loading_modprobe
    - audit_rules_kernel_module_loading_init
    - audit_rules_kernel_module_loading_rmmod
    - audit_rules_kernel_module_loading_insmod
    - audit_rules_usergroup_modification_shadow
    - audit_rules_usergroup_modification_group
    - audit_rules_dac_modification_lchown
    - audit_rules_dac_modification_fchownat
    - audit_rules_dac_modification_setxattr
    - audit_rules_dac_modification_chmod
    - audit_rules_dac_modification_removexattr
    - audit_rules_dac_modification_lsetxattr
    - audit_rules_dac_modification_chown
    - audit_rules_dac_modification_fremovexattr
    - audit_rules_dac_modification_lremovexattr
    - audit_rules_dac_modification_fchmod
    - audit_rules_dac_modification_fchmodat
    - audit_rules_dac_modification_fsetxattr
    - audit_rules_dac_modification_fchown
    - audit_rules_usergroup_modification_opasswd
    - audit_rules_usergroup_modification_gshadow
    - grub2_audit_argument
    - service_auditd_enabled
    - auditd_data_retention_max_log_file
    - auditd_audispd_syslog_plugin_activated
    - auditd_data_retention_max_log_file_action
    - auditd_data_retention_space_left_action
    - auditd_data_retention_admin_space_left_action
    - auditd_data_disk_error_action
    - auditd_data_retention_space_left
    - auditd_data_disk_full_action
    - auditd_data_retention_action_mail_acct
    - auditd_data_retention_num_logs 

    # AC-19
    - mount_option_nosuid_removable_partitions
    - mount_option_noexec_removable_partitions
    - mount_option_nodev_removable_partitions
    - kernel_module_usb-storage_disabled
    - bios_disable_usb_boot
    - grub2_nousb_argument
    - service_autofs_disabled

    # AC-18
    - wireless_disable_interfaces
    - wireless_disable_in_bios
    - kernel_module_bluetooth_disabled
    - service_bluetooth_disabled




    - grub2_enable_fips_mode
    - package_dracut-fips_installed
    - sysctl_net_ipv4_conf_default_log_martians
    - sysctl_net_ipv4_conf_all_log_martians
    - package_libreswan_installed
    - configure_firewalld_ports
    - kernel_module_bluetooth_disabled
    - service_bluetooth_disabled




