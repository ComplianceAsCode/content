documentation_complete: true

title: 'PCI-DSS v3 Control Baseline Draft for Oracle Linux 7'

description: 'Ensures PCI-DSS v3 related security configuration settings are applied.'

selections:
    - rpm_verify_permissions
    - rpm_verify_hashes
    - rsyslog_files_permissions
    - rsyslog_files_ownership
    - rsyslog_files_groupownership
    - accounts_password_all_shadowed
    - no_empty_passwords
    - ensure_oracle_gpgkey_installed
    - ensure_gpgcheck_globally_activated
    - ensure_gpgcheck_never_disabled
    - security_patches_up_to_date
    - file_owner_etc_shadow
    - file_groupowner_etc_shadow
    - file_permissions_etc_shadow
    - file_owner_etc_group
    - file_groupowner_etc_group
    - file_permissions_etc_group
    - file_owner_etc_passwd
    - file_groupowner_etc_passwd
    - file_permissions_etc_passwd
    - file_owner_grub2_cfg
    - file_groupowner_grub2_cfg
    - package_libreswan_installed
    - set_password_hashing_algorithm_systemauth
    - set_password_hashing_algorithm_logindefs
    - set_password_hashing_algorithm_libuserconf
    - package_aide_installed
    - aide_build_database
    - aide_periodic_cron_checking
