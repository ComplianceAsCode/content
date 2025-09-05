documentation_complete: true

title: 'Standard System Security Profile for Oracle Linux 8'

description: |-
    This profile contains rules to ensure standard security baseline
    of Oracle Linux 8 system. Regardless of your system's workload
    all of these checks should pass.

selections:
    - ensure_oracle_gpgkey_installed
    - ensure_gpgcheck_globally_activated
    - security_patches_up_to_date
    - rpm_verify_permissions
    - rpm_verify_hashes
    - no_empty_passwords
    - file_permissions_unauthorized_sgid
    - file_permissions_unauthorized_suid
    - file_permissions_unauthorized_world_writable
    - accounts_root_path_dirs_no_write
    - dir_perms_world_writable_sticky_bits
    - root_path_no_dot
    - accounts_password_all_shadowed
    - mount_option_dev_shm_nodev
    - mount_option_dev_shm_nosuid
    - audit_rules_privileged_commands_at
    - audit_rules_privileged_commands_chage
    - audit_rules_privileged_commands_chsh
    - audit_rules_privileged_commands_crontab
    - audit_rules_privileged_commands_gpasswd
    - audit_rules_privileged_commands_mount
    - audit_rules_privileged_commands_newgrp
    - audit_rules_privileged_commands_pam_timestamp_check
    - audit_rules_privileged_commands_passwd
    - audit_rules_privileged_commands_postdrop
    - audit_rules_privileged_commands_postqueue
    - audit_rules_privileged_commands_ssh_keysign
    - audit_rules_privileged_commands_su
    - audit_rules_privileged_commands_sudo
    - audit_rules_privileged_commands_sudoedit
    - audit_rules_privileged_commands_umount
    - audit_rules_privileged_commands_unix_chkpwd
    - audit_rules_privileged_commands_userhelper
    - audit_rules_privileged_commands_usernetctl
    - audit_rules_dac_modification_chmod
    - audit_rules_dac_modification_chown
    - audit_rules_dac_modification_fchmod
    - audit_rules_dac_modification_fchmodat
    - audit_rules_dac_modification_fchown
    - audit_rules_dac_modification_fchownat
    - audit_rules_dac_modification_fremovexattr
    - audit_rules_dac_modification_fsetxattr
    - audit_rules_dac_modification_lchown
    - audit_rules_dac_modification_lremovexattr
    - audit_rules_dac_modification_lsetxattr
    - audit_rules_dac_modification_removexattr
    - audit_rules_dac_modification_setxattr
    - audit_rules_file_deletion_events
    - audit_rules_kernel_module_loading
    - audit_rules_mac_modification
    - audit_rules_media_export
    - audit_rules_networkconfig_modification
    - audit_rules_sysadmin_actions
    - audit_rules_time_adjtimex
    - audit_rules_time_clock_settime
    - audit_rules_time_settimeofday
    - audit_rules_time_stime
    - audit_rules_time_watch_localtime
    - audit_rules_unsuccessful_file_modification
    - audit_rules_usergroup_modification
    - package_rsyslog_installed
    - service_abrtd_disabled
    - service_atd_disabled
    - service_autofs_disabled
    - service_ntpdate_disabled
    - service_oddjobd_disabled
    - service_rdisc_disabled
    - service_rsyslog_enabled
    - partition_for_var_log
    - partition_for_var_log_audit
    - configure_crypto_policy
    - configure_bind_crypto_policy
    - configure_openssl_crypto_policy
    - configure_libreswan_crypto_policy
    - configure_ssh_crypto_policy
    - configure_kerberos_crypto_policy
