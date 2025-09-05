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
    - accounts_maximum_age_login_defs
    - accounts_no_uid_except_zero
    - accounts_password_set_max_life_existing
    - accounts_password_set_min_life_existing
    - accounts_umask_etc_login_defs
    - auditd_data_disk_full_action
    - auditd_data_retention_action_mail_acct
    - auditd_data_retention_space_left
    - banner_etc_motd
    - disable_ctrlaltdel_reboot
    - gnome_gdm_disable_automatic_login
    - grub2_password
    - grub2_uefi_password
    - installed_OS_is_vendor_supported
    - no_empty_passwords
    - no_host_based_files
    - no_user_host_based_files
    - package_audit-audispd-plugins_installed
    - package_audit_installed
    - postfix_client_configure_mail_alias
    - security_patches_up_to_date
    - service_auditd_enabled
    - set_password_hashing_algorithm_logindefs
    - sshd_disable_empty_passwords
    - sshd_disable_user_known_hosts
    - sshd_do_not_permit_user_env
    - sshd_enable_x11_forwarding
    - sshd_set_idle_timeout
    - sshd_set_keepalive
    - sudo_remove_no_authenticate
    - sudo_remove_nopasswd
