documentation_complete: true

title: 'DISA STIG for Red Hat Enterprise Linux 6'

description: |-
    This profile contains configuration checks that align to the
    DISA STIG for Red Hat Enterprise Linux 6.

    In addition to being applicable to RHEL6, DISA recognizes this
    configuration baseline as applicable to the operating system
    tier of Red Hat technologies that are based off RHEL6, such as RHEL
    Server,  RHV-H, RHEL for HPC, RHEL Workstation, and Red Hat
    Storage deployments.

extends: standard

selections:
    - encrypt_partitions
    - kernel_disable_entropy_contribution_for_solid_state_drives
    - rpm_verify_permissions
    - rpm_verify_hashes
    - mount_option_nodev_removable_partitions
    - mount_option_noexec_removable_partitions
    - mount_option_nosuid_removable_partitions
    - mount_option_dev_shm_nodev
    - mount_option_dev_shm_nosuid
    - mount_option_dev_shm_noexec
    - mount_option_tmp_noexec
    - file_permissions_unauthorized_world_writable
    - install_antivirus
    - install_hids
    - disable_ctrlaltdel_reboot
    - service_postfix_enabled
    - package_sendmail_removed
    - service_netconsole_disabled
    - service_atd_disabled
    - xwindows_runlevel_setting
    - package_xorg-x11-server-common_removed
    - sysconfig_networking_bootproto_ifcfg
    - accounts_password_pam_unix_remember
    - gid_passwd_group_same
    - account_unique_name
    - account_temp_expire_date
    - accounts_password_pam_maxrepeat
    - no_files_unowned_by_user
    - file_permissions_ungroupowned
    - aide_periodic_cron_checking
    - disable_users_coredumps
    - no_insecure_locks_exports
    - auditd_data_retention_space_left_action
    - auditd_data_retention_action_mail_acct
    - gconf_gnome_screen_locking_keybindings
    - no_all_squash_exports
    - sshd_print_last_log
    - auditd_data_retention_space_left
    - auditd_data_disk_full_action
    - auditd_data_disk_error_action
    - directory_permissions_var_log_audit
    - rpm_verify_ownership
    - kernel_module_bluetooth_disabled
    - kernel_module_usb-storage_disabled
    - accounts_max_concurrent_login_sessions
    - var_accounts_max_concurrent_login_sessions=10
    - set_iptables_default_rule_forward
    - package_openswan_installed
    - gconf_gdm_enable_warning_gui_banner
    - gconf_gdm_set_login_banner_text
    - login_banner_text=dod_banners
    - gconf_gdm_disable_user_list
    - service_bluetooth_disabled
    - account_disable_post_pw_expiration
    - dir_perms_world_writable_sticky_bits
    - dir_perms_world_writable_system_owned
    - tftpd_uses_secure_mode
    - ftp_log_transactions
    - snmpd_use_newer_protocol
    - snmpd_not_default_password
    - accounts_umask_etc_bashrc
    - accounts_umask_etc_csh_cshrc
    - accounts_umask_etc_profile
    - accounts_umask_etc_login_defs
    - var_accounts_user_umask=077
    - umask_for_daemons
    - var_umask_for_daemons=027
    - no_netrc_files
    - ftp_present_banner
    - smartcard_auth
    - display_login_attempts
    - accounts_passwords_pam_faillock_unlock_time
    - var_accounts_passwords_pam_faillock_unlock_time=604800
    - accounts_passwords_pam_faillock_interval
    - var_accounts_passwords_pam_faillock_fail_interval=900
    - var_password_pam_unix_remember=5
    - var_accounts_maximum_age_login_defs=60
    - var_accounts_minimum_age_login_defs=1
    - var_accounts_passwords_pam_faillock_deny=3
    - var_password_pam_ucredit=1
    - var_password_pam_ocredit=1
    - var_password_pam_lcredit=1
    - sshd_idle_timeout_value=15_minutes
    - gconf_gnome_disable_ctrlaltdel_reboot
    - postfix_client_configure_mail_alias
    - account_use_centralized_automated_auth
    - no_password_auth_for_systemaccounts
    - wireless_disable_interfaces
    - configure_user_data_backups
