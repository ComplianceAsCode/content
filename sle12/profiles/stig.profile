documentation_complete: true

title: 'DISA STIG for SUSE Linux Enterprise 12'

description: |-
    This profile contains configuration checks that align to the
    DISA STIG for SUSE Linux Enterprise 12 V1R2.

selections:
    - var_accounts_fail_delay=4
    - installed_OS_is_vendor_supported
    - security_patches_up_to_date
    - sudo_remove_nopasswd
    - sudo_remove_no_authenticate
    - sshd_disable_empty_passwords
    - sshd_do_not_permit_user_env
    - gnome_gdm_disable_automatic_login
    - disable_ctrlaltdel_reboot
    - sshd_enable_x11_forwarding
    - no_user_host_based_files
    - auditd_data_disk_full_action
    - postfix_client_configure_mail_alias
    - accounts_logon_fail_delay 
    - no_host_based_files
    - banner_etc_motd
    - accounts_no_uid_except_zero
    - no_user_host_based_files
    - no_user_host_based_files
    - package_audit_installed
    - service_auditd_enabled
    - auditd_data_retention_space_left
