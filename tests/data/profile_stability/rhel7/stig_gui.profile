description: 'This profile contains configuration checks that align to the

    DISA STIG with GUI for Red Hat Enterprise Linux V3R14.


    In addition to being applicable to Red Hat Enterprise Linux 7, DISA recognizes
    this

    configuration baseline as applicable to the operating system tier of

    Red Hat technologies that are based on Red Hat Enterprise Linux 7, such as:


    - Red Hat Enterprise Linux Server

    - Red Hat Enterprise Linux Workstation and Desktop

    - Red Hat Enterprise Linux for HPC

    - Red Hat Storage

    - Red Hat Containers with a Red Hat Enterprise Linux 7 image


    Warning: The installation and use of a Graphical User Interface (GUI)

    increases your attack vector and decreases your overall security posture. If

    your Information Systems Security Officer (ISSO) lacks a documented operational

    requirement for a graphical user interface, please consider using the

    standard DISA STIG for Red Hat Enterprise Linux 7 profile.'
extends: null
hidden: ''
metadata:
    version: V3R14
    SMEs:
    - ggbecker
reference: https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux
selections:
- mount_option_dev_shm_noexec
- grub2_enable_fips_mode
- sshd_disable_rhosts_rsa
- auditd_audispd_remote_daemon_type
- mount_option_nosuid_remote_filesystems
- sudo_remove_nopasswd
- sssd_ldap_configure_tls_reqcert
- sssd_enable_pam_services
- account_disable_post_pw_expiration
- accounts_umask_interactive_users
- dconf_gnome_screensaver_lock_enabled
- sysctl_net_ipv4_conf_all_rp_filter
- accounts_user_dot_user_ownership
- audit_rules_system_shutdown
- dconf_gnome_banner_enabled
- service_sshd_enabled
- auditd_audispd_remote_daemon_activated
- dconf_gnome_screensaver_lock_delay
- installed_OS_is_vendor_supported
- audit_rules_dac_modification_lsetxattr
- audit_rules_suid_privilege_function
- package_rsh-server_removed
- audit_rules_execution_semanage
- account_temp_expire_date
- dconf_gnome_disable_ctrlaltdel_reboot
- accounts_user_home_paths_only
- audit_rules_usergroup_modification_group
- mount_option_nosuid_removable_partitions
- selinux_confine_to_least_privilege
- dconf_gnome_disable_automount
- auditd_data_retention_action_mail_acct
- clean_components_post_updating
- audit_rules_privileged_commands_pam_timestamp_check
- audit_rules_dac_modification_fchownat
- file_permissions_sshd_pub_key
- sysctl_net_ipv4_conf_default_rp_filter
- audit_rules_privileged_commands_mount
- grub2_password
- dconf_gnome_disable_autorun
- dconf_gnome_login_banner_text
- sysctl_net_ipv6_conf_all_accept_source_route
- accounts_passwords_pam_faillock_interval
- gnome_gdm_disable_guest_login
- audit_rules_privileged_commands_userhelper
- auditd_audispd_configure_remote_server
- dconf_gnome_screensaver_idle_activation_enabled
- sshd_enable_warning_banner
- sshd_disable_compression
- accounts_password_pam_minlen
- audit_rules_usergroup_modification_passwd
- audit_rules_dac_modification_fchmod
- audit_rules_unsuccessful_file_modification_open_by_handle_at
- ensure_redhat_gpgkey_installed
- dconf_gnome_session_idle_user_locks
- audit_rules_privileged_commands_unix_chkpwd
- grub2_admin_username
- audit_rules_execution_chcon
- mount_option_dev_shm_nosuid
- aide_use_fips_hashes
- banner_etc_issue
- package_screen_installed
- rsyslog_remote_loghost
- sshd_allow_only_protocol2
- sysctl_net_ipv4_conf_all_accept_source_route
- accounts_passwords_pam_faillock_deny
- package_mailx_installed
- audit_rules_sysadmin_actions
- dconf_gnome_enable_smartcard_auth
- mount_option_noexec_remote_filesystems
- set_password_hashing_algorithm_passwordauth
- audit_rules_privileged_commands_umount
- accounts_users_home_files_ownership
- file_permissions_var_log_audit
- audit_rules_dac_modification_chmod
- accounts_password_pam_pwhistory_remember_password_auth
- accounts_passwords_pam_faillock_deny_root
- audit_rules_dac_modification_lchown
- audit_rules_unsuccessful_file_modification_truncate
- mount_option_dev_shm_nodev
- audit_rules_dac_modification_fsetxattr
- ensure_gpgcheck_globally_activated
- auditd_name_format
- file_groupownership_home_directories
- gid_passwd_group_same
- audit_rules_file_deletion_events_unlink
- sshd_set_keepalive_0
- sysctl_net_ipv4_conf_all_accept_redirects
- kernel_module_dccp_disabled
- package_ypserv_removed
- accounts_password_pam_retry
- file_permissions_home_directories
- partition_for_tmp
- wireless_disable_interfaces
- agent_mfetpd_running
- audit_rules_dac_modification_setxattr
- audit_rules_unsuccessful_file_modification_open
- sshd_x11_use_localhost
- mount_option_krb_sec_remote_filesystems
- audit_rules_login_events_lastlog
- auditd_audispd_remote_daemon_path
- dir_perms_world_writable_system_owned_group
- audit_rules_kernel_module_loading_create
- accounts_minimum_age_login_defs
- audit_rules_file_deletion_events_rmdir
- audit_rules_login_events_faillock
- disable_host_auth
- partition_for_home
- rpm_verify_hashes
- rpm_verify_permissions
- libreswan_approved_tunnels
- sshd_disable_user_known_hosts
- audit_rules_usergroup_modification_shadow
- network_sniffer_disabled
- audit_rules_dac_modification_lremovexattr
- mount_option_home_nosuid
- display_login_attempts
- auditd_audispd_disk_full_action
- audit_rules_dac_modification_fchown
- accounts_have_homedir_login_defs
- audit_rules_unsuccessful_file_modification_openat
- package_vsftpd_removed
- sshd_disable_empty_passwords
- security_patches_up_to_date
- accounts_password_pam_difok
- smartcard_auth
- sysctl_net_ipv4_icmp_echo_ignore_broadcasts
- sshd_do_not_permit_user_env
- rpm_verify_ownership
- audit_rules_privileged_commands_chage
- accounts_user_interactive_home_directory_exists
- audit_rules_dac_modification_fremovexattr
- smartcard_configure_cert_checking
- accounts_maximum_age_login_defs
- audit_rules_file_deletion_events_renameat
- sshd_disable_rhosts
- auditd_overflow_action
- file_owner_cron_allow
- selinux_all_devicefiles_labeled
- sudoers_validate_passwd
- sysctl_kernel_dmesg_restrict
- accounts_users_home_files_permissions
- snmpd_not_default_password
- sshd_disable_root_login
- accounts_authorized_local_users
- audit_rules_privileged_commands_newgrp
- dconf_gnome_screensaver_lock_locked
- disable_ctrlaltdel_reboot
- file_ownership_var_log_audit
- postfix_prevent_unrestricted_relay
- selinux_state
- sudo_require_reauthentication
- tftpd_uses_secure_mode
- aide_verify_ext_attributes
- sysctl_net_ipv4_conf_default_accept_redirects
- no_empty_passwords
- accounts_password_set_min_life_existing
- dconf_gnome_screensaver_idle_activation_locked
- sshd_use_approved_kex_ordered_stig
- sudoers_default_includedir
- auditd_data_retention_space_left_action
- no_host_based_files
- sudo_remove_no_authenticate
- configure_firewalld_ports
- selinux_policytype
- file_ownership_home_directories
- grub2_no_removeable_media
- sshd_set_idle_timeout
- sysctl_net_ipv4_conf_all_send_redirects
- set_password_hashing_algorithm_systemauth
- dconf_gnome_screensaver_user_locks
- accounts_password_pam_ucredit
- accounts_password_pam_maxclassrepeat
- audit_rules_dac_modification_chown
- dconf_gnome_screensaver_idle_delay
- rsyslog_cron_logging
- rsyslog_nolisten
- audit_rules_privileged_commands_passwd
- sshd_disable_gssapi_auth
- sshd_print_last_log
- aide_verify_acls
- audit_rules_privileged_commands_crontab
- dir_perms_world_writable_system_owned
- audit_rules_privileged_commands_gpasswd
- sudo_restrict_privilege_elevation_to_authorized
- accounts_password_pam_pwhistory_remember_system_auth
- accounts_max_concurrent_login_sessions
- aide_build_database
- kernel_module_usb-storage_disabled
- set_firewalld_default_zone
- auditd_data_retention_space_left_percentage
- package_aide_installed
- package_mcafeetp_installed
- audit_rules_media_export
- service_auditd_enabled
- service_firewalld_enabled
- sshd_use_approved_macs_ordered_stig
- sysctl_net_ipv4_conf_default_accept_source_route
- audit_rules_privileged_commands_chsh
- accounts_tmout
- install_smartcard_packages
- accounts_password_set_max_life_existing
- ensure_gpgcheck_local_packages
- sshd_disable_kerb_auth
- sshd_disable_x11_forwarding
- service_autofs_disabled
- no_user_host_based_files
- audit_rules_privileged_commands_su
- accounts_password_pam_ocredit
- accounts_password_pam_dcredit
- audit_rules_execution_setsebool
- sysctl_net_ipv4_conf_default_send_redirects
- audit_rules_privileged_commands_kmod
- accounts_umask_etc_login_defs
- network_configure_name_resolution
- grub2_uefi_password
- accounts_user_dot_no_world_writable_programs
- set_password_hashing_algorithm_logindefs
- file_permissions_sshd_private_key
- sshd_enable_strictmodes
- sysctl_kernel_randomize_va_space
- auditd_audispd_network_failure_action
- package_openssh-server_installed
- grub2_uefi_admin_username
- accounts_password_pam_maxrepeat
- authconfig_config_files_symlinks
- accounts_no_uid_except_zero
- accounts_password_pam_lcredit
- sssd_ldap_start_tls
- accounts_passwords_pam_faillock_unlock_time
- audit_rules_file_deletion_events_rename
- audit_rules_kernel_module_loading_delete
- audit_rules_file_deletion_events_unlinkat
- partition_for_var
- auditd_audispd_remote_daemon_direction
- sebool_ssh_sysadm_login
- audit_rules_kernel_module_loading_finit
- chronyd_or_ntpd_set_maxpoll
- sshd_use_approved_ciphers_ordered_stig
- audit_rules_dac_modification_removexattr
- audit_rules_privileged_commands_postqueue
- auditd_audispd_encrypt_sent_records
- audit_rules_usergroup_modification_gshadow
- dconf_db_up_to_date
- install_antivirus
- audit_rules_dac_modification_fchmodat
- file_groupowner_cron_allow
- audit_rules_unsuccessful_file_modification_creat
- no_empty_passwords_etc_shadow
- aide_periodic_cron_checking
- accounts_logon_fail_delay
- require_singleuser_auth
- disallow_bypass_password_sudo
- sssd_ldap_configure_tls_ca
- sysctl_net_ipv4_ip_forward
- audit_rules_execution_setfiles
- selinux_user_login_roles
- package_tftp-server_removed
- audit_rules_unsuccessful_file_modification_ftruncate
- audit_rules_privileged_commands_postdrop
- file_permission_user_init_files
- gnome_gdm_disable_automatic_login
- uefi_no_removeable_media
- audit_rules_kernel_module_loading_init
- accounts_users_home_files_groupownership
- aide_scan_notification
- file_permissions_ungroupowned
- dconf_gnome_disable_automount_open
- no_files_unowned_by_user
- package_telnet-server_removed
- partition_for_var_log_audit
- audit_rules_privileged_commands_ssh_keysign
- audit_rules_usergroup_modification_opasswd
- accounts_user_dot_group_ownership
- audit_rules_privileged_commands_sudo
- dconf_gnome_disable_user_list
- set_password_hashing_algorithm_libuserconf
- service_kdump_disabled
- accounts_password_pam_minclass
- selinux_context_elevation_for_sudo
- sshd_use_priv_separation
- login_banner_text=dod_banners
- inactivity_timeout_value=15_minutes
- var_screensaver_lock_delay=5_seconds
- sshd_idle_timeout_value=10_minutes
- var_accounts_fail_delay=4
- var_selinux_state=enforcing
- var_selinux_policy_name=targeted
- var_password_pam_minlen=15
- var_password_pam_ocredit=1
- var_password_pam_lcredit=1
- var_password_pam_ucredit=1
- var_accounts_passwords_pam_faillock_unlock_time=never
- var_accounts_passwords_pam_faillock_fail_interval=900
- var_accounts_passwords_pam_faillock_deny=3
- var_password_pam_unix_remember=5
- var_password_pam_maxclassrepeat=4
- var_password_pam_difok=8
- var_password_pam_dcredit=1
- var_password_pam_minclass=4
- var_accounts_minimum_age_login_defs=1
- var_password_pam_maxrepeat=3
- var_accounts_maximum_age_login_defs=60
- var_account_disable_post_pw_expiration=35
- var_removable_partition=dev_cdrom
- var_auditd_action_mail_acct=root
- var_auditd_space_left_action=email
- var_auditd_space_left_percentage=25pc
- var_accounts_user_umask=077
- var_password_pam_retry=3
- var_accounts_max_concurrent_login_sessions=10
- var_accounts_tmout=15_min
- var_accounts_authorized_local_users_regex=rhel7
- var_time_service_set_maxpoll=18_hours
- sysctl_net_ipv4_conf_all_accept_source_route_value=disabled
- sysctl_net_ipv4_conf_default_accept_source_route_value=disabled
- sysctl_net_ipv4_icmp_echo_ignore_broadcasts_value=enabled
- sysctl_net_ipv4_conf_default_accept_redirects_value=disabled
- sysctl_net_ipv6_conf_all_accept_source_route_value=disabled
- sysctl_net_ipv4_conf_all_accept_redirects_value=disabled
- var_audit_failure_mode=panic
- var_accounts_passwords_pam_faillock_dir=run
- sshd_required=yes
- var_sshd_set_keepalive=0
- var_auditd_name_format=stig
- sssd_ldap_start_tls.severity=medium
unselected_groups: []
platforms: !!set {}
cpe_names: !!set {}
platform: null
filter_rules: ''
policies: []
title: DISA STIG with GUI for Red Hat Enterprise Linux 7
definition_location: /home/jcerny/work/git/content/products/rhel7/profiles/stig_gui.profile
documentation_complete: true
