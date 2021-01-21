documentation_complete: true

title: 'DISA STIG for SUSE Linux Enterprise 12'

description: |-
    This profile contains configuration checks that align to the
    DISA STIG for SUSE Linux Enterprise 12 V1R2.

selections:
    - var_accounts_fail_delay=4
    - account_disable_post_pw_expiration
    - account_temp_expire_date
    - accounts_have_homedir_login_defs
    - accounts_logon_fail_delay
    - accounts_max_concurrent_login_sessions
    - accounts_maximum_age_login_defs
    - accounts_minimum_age_login_defs
    - accounts_no_uid_except_zero
    - accounts_password_set_max_life_existing
    - accounts_password_set_min_life_existing
    - accounts_umask_etc_login_defs
    - auditd_audispd_encrypt_sent_records
    - auditd_data_disk_full_action
    - auditd_data_retention_action_mail_acct
    - auditd_data_retention_space_left
    - banner_etc_issue
    - banner_etc_motd
    - dir_perms_world_writable_sticky_bits
    - disable_ctrlaltdel_reboot
    - encrypt_partitions
    - ensure_gpgcheck_globally_activated
    - file_permissions_sshd_private_key
    - file_permissions_sshd_pub_key
    - ftp_present_banner
    - gnome_gdm_disable_automatic_login
    - grub2_password
    - grub2_uefi_password
    - installed_OS_is_vendor_supported
    - kernel_module_usb-storage_disabled
    - no_empty_passwords
    - no_files_unowned_by_user
    - no_host_based_files
    - no_user_host_based_files
    - package_MFEhiplsm_installed
    - package_aide_installed
    - package_audit-audispd-plugins_installed
    - package_audit_installed
    - package_telnet-server_removed
    - postfix_client_configure_mail_alias
    - security_patches_up_to_date
    - service_auditd_enabled
    - set_password_hashing_algorithm_logindefs
    - sshd_disable_compression
    - sshd_disable_empty_passwords
    - sshd_disable_user_known_hosts
    - sshd_do_not_permit_user_env
    - sshd_enable_strictmodes
    - sshd_enable_warning_banner
    - sshd_enable_x11_forwarding
    - sshd_print_last_log
    - sshd_set_idle_timeout
    - sshd_set_keepalive
    - sshd_set_loglevel_verbose
    - sshd_use_priv_separation
    - sudo_remove_no_authenticate
    - sudo_remove_nopasswd
    - sysctl_net_ipv4_conf_all_accept_source_route
    - sysctl_net_ipv4_conf_default_accept_source_route
    - sysctl_net_ipv4_conf_default_send_redirects
    - sysctl_net_ipv6_conf_all_accept_source_route
