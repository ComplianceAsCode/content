documentation_complete: true

metadata:
    version: V1R9

reference: https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: 'DISA STIG for Oracle Linux 8'

description: |-
    This profile contains configuration checks that align to the
    DISA STIG for Oracle Linux 8 V1R9.

selections:
    ### Variables
    - var_rekey_limit_size=1G
    - var_rekey_limit_time=1hour
    - var_accounts_user_umask=077
    - var_password_pam_difok=8
    - var_password_pam_maxrepeat=3
    - var_password_hashing_algorithm=SHA512
    - var_password_pam_maxclassrepeat=4
    - var_password_pam_minclass=4
    - var_accounts_minimum_age_login_defs=1
    - var_accounts_max_concurrent_login_sessions=10
    - var_password_pam_remember=5
    - var_password_pam_remember_control_flag=ol8
    - var_selinux_state=enforcing
    - var_selinux_policy_name=targeted
    - var_accounts_password_minlen_login_defs=15
    - var_password_pam_unix_rounds=5000
    - var_password_pam_minlen=15
    - var_password_pam_ocredit=1
    - var_password_pam_dcredit=1
    - var_password_pam_dictcheck=1
    - var_password_pam_ucredit=1
    - var_password_pam_lcredit=1
    - var_password_pam_retry=3
    - var_password_pam_minlen=15
    - var_sshd_set_keepalive=0
    - sshd_approved_macs=stig_extended
    - sshd_approved_ciphers=stig_extended
    - sshd_idle_timeout_value=10_minutes
    - var_accounts_authorized_local_users_regex=ol8
    - var_accounts_passwords_pam_faillock_deny=3
    - var_accounts_passwords_pam_faillock_dir=ol8
    - var_accounts_passwords_pam_faillock_fail_interval=900
    - var_accounts_passwords_pam_faillock_unlock_time=never
    - var_ssh_client_rekey_limit_size=1G
    - var_ssh_client_rekey_limit_time=1hour
    - var_accounts_fail_delay=4
    - var_account_disable_post_pw_expiration=35
    - var_account_disable_inactivity=35
    - var_auditd_action_mail_acct=root
    - var_time_service_set_maxpoll=18_hours
    - var_accounts_maximum_age_login_defs=60
    - var_auditd_space_left_percentage=25pc
    - var_auditd_space_left_action=email
    - var_auditd_disk_error_action=ol8
    - var_auditd_max_log_file_action=syslog
    - var_auditd_disk_full_action=ol8
    - var_sssd_certificate_verification_digest_function=sha1
    - login_banner_text=dod_banners

    ### Enable / Configure FIPS
    - enable_fips_mode
    - var_system_crypto_policy=fips
    - configure_crypto_policy
    - configure_bind_crypto_policy
    - configure_libreswan_crypto_policy
    - configure_kerberos_crypto_policy
    - enable_dracut_fips_module

    ### Rules:
    # OL08-00-010000
    - installed_OS_is_vendor_supported

    # OL08-00-010001
    - package_mcafeetp_installed
    - agent_mfetpd_running

    # OL08-00-010010
    - security_patches_up_to_date

    # OL08-00-010019
    - ensure_oracle_gpgkey_installed

    # OL08-00-010020
    - sysctl_crypto_fips_enabled
    - harden_sshd_ciphers_openssh_conf_crypto_policy
    - harden_sshd_ciphers_openssh_conf_crypto_policy.severity=high

    # OL08-00-010030
    - encrypt_partitions
    - encrypt_partitions.severity=medium

    # OL08-00-010040
    - sshd_enable_warning_banner

    # OL08-00-010049
    - dconf_gnome_banner_enabled

    # OL08-00-010050
    - dconf_gnome_login_banner_text

    # OL08-00-010060
    - banner_etc_issue

    # OL08-00-010070
    - rsyslog_remote_access_monitoring

    # OL08-00-010090
    - sssd_has_trust_anchor

    # OL08-00-010100
    - ssh_private_keys_have_passcode

    # OL08-00-010110
    - set_password_hashing_algorithm_logindefs

    # OL08-00-010120
    - accounts_password_all_shadowed_sha512

    # OL08-00-010121
    - no_empty_passwords_etc_shadow

    # OL08-00-010130
    - set_password_hashing_min_rounds_logindefs

    # OL08-00-010140
    - grub2_uefi_password

    # OL08-00-010141
    - grub2_uefi_admin_username

    # OL08-00-010149
    - grub2_admin_username

    # OL08-00-010150
    - grub2_password

    # OL08-00-010151
    - require_singleuser_auth

    # OL08-00-010152
    - require_emergency_target_auth

    # OL08-00-010159
    - set_password_hashing_algorithm_systemauth

    # OL08-00-010160
    - set_password_hashing_algorithm_passwordauth

    # OL08-00-010161
    - kerberos_disable_no_keytab

    # OL08-00-010162
    - package_krb5-workstation_removed

    # OL08-00-010170
    - selinux_state

    # OL08-00-010171
    - package_policycoreutils_installed

    # OL08-00-010190
    - dir_perms_world_writable_sticky_bits

    # OL08-00-010200
    - sshd_set_keepalive_0

    # OL08-00-010201
    - sshd_set_idle_timeout

    # OL08-00-010210
    - file_permissions_var_log_messages

    # OL08-00-010220
    - file_owner_var_log_messages

    # OL08-00-010230
    - file_groupowner_var_log_messages

    # OL08-00-010240
    - file_permissions_var_log

    # OL08-00-010250
    - file_owner_var_log

    # OL08-00-010260
    - file_groupowner_var_log

    # OL08-00-010287
    - configure_ssh_crypto_policy

    # OL08-00-010290
    - harden_sshd_macs_openssh_conf_crypto_policy
    - harden_sshd_macs_opensshserver_conf_crypto_policy

    # OL08-00-010291
    - harden_sshd_ciphers_opensshserver_conf_crypto_policy

    # OL08-00-010292
    - sshd_use_strong_rng

    # OL08-00-010293
    - configure_openssl_crypto_policy

    # OL08-00-010294
    - configure_openssl_tls_crypto_policy

    # OL08-00-010295
    - configure_gnutls_tls_crypto_policy

    # OL08-00-010300
    - file_permissions_binary_dirs

    # OL08-00-010310
    - file_ownership_binary_dirs

    # OL08-00-010320
    - file_groupownership_system_commands_dirs

    # OL08-00-010330
    - file_permissions_library_dirs

    # OL08-00-010331
    - dir_permissions_library_dirs

    # OL08-00-010340
    - file_ownership_library_dirs

    # OL08-00-010341
    - dir_ownership_library_dirs

    # OL08-00-010350
    - root_permissions_syslibrary_files

    # OL08-00-010351
    - dir_group_ownership_library_dirs

    # OL08-00-010358
    - package_mailx_installed

    # OL08-00-010359
    - package_aide_installed
    - aide_build_database

    # OL08-00-010360
    - aide_scan_notification

    # OL08-00-010370
    - ensure_gpgcheck_globally_activated
    - ensure_gpgcheck_never_disabled

    # OL08-00-010371
    - ensure_gpgcheck_local_packages

    # OL08-00-010372
    - sysctl_kernel_kexec_load_disabled

    # OL08-00-010373
    - sysctl_fs_protected_symlinks

    # OL08-00-010374
    - sysctl_fs_protected_hardlinks

    # OL08-00-010375
    - sysctl_kernel_dmesg_restrict

    # OL08-00-010376
    - sysctl_kernel_perf_event_paranoid

    # OL08-00-010379
    - sudoers_default_includedir

    # OL08-00-010380
    - sudo_remove_nopasswd

    # OL08-00-010381
    - sudo_remove_no_authenticate

    # OL08-00-010382
    - sudo_restrict_privilege_elevation_to_authorized

    # OL08-00-010383
    - sudoers_validate_passwd

    # OL08-00-010384
    - sudo_require_reauthentication
    - var_sudo_timestamp_timeout=always_prompt

    # OL08-00-010385
    - disallow_bypass_password_sudo

    # OL08-00-010390
    - install_smartcard_packages
    - install_smartcard_packages.severity=low

    # OL08-00-010400
    - sssd_certificate_verification

    # OL08-00-010410
    - package_opensc_installed

    # OL08-00-010420
    - bios_enable_execution_restrictions

    # OL08-00-010421
    - grub2_page_poison_argument

    # OL08-00-010422
    - grub2_vsyscall_argument

    # OL08-00-010423
    - grub2_slub_debug_argument

    # OL08-00-010424
    - grub2_mitigation_argument

    # OL08-00-010430
    - sysctl_kernel_randomize_va_space

    # OL08-00-010440
    - clean_components_post_updating

    # OL08-00-010450
    - selinux_policytype

    # OL08-00-010460
    - no_host_based_files

    # OL08-00-010470
    - no_user_host_based_files

    # OL08-00-010471
    - service_rngd_enabled

    # OL08-00-010472
    - package_rng-tools_installed

    # OL08-00-010480
    - file_permissions_sshd_pub_key

    # OL08-00-010490
    - file_permissions_sshd_private_key

    # OL08-00-010500
    - sshd_enable_strictmodes

    # OL08-00-010520
    - sshd_disable_user_known_hosts

    # OL08-00-010521
    - sshd_disable_kerb_auth

    # OL08-00-010522
    - sshd_disable_gssapi_auth

    # OL08-00-010540
    - partition_for_var

    # OL08-00-010541
    - partition_for_var_log

    # OL08-00-010542
    - partition_for_var_log_audit

    # OL08-00-010543
    - partition_for_tmp
    - partition_for_tmp.severity=medium

    # OL08-00-010544
    - partition_for_var_tmp

    # OL08-00-010550
    - sshd_disable_root_login

    # OL08-00-010561
    - service_rsyslog_enabled

    # OL08-00-010570
    - mount_option_home_nosuid

    # OL08-00-010571
    - mount_option_boot_nosuid

    # OL08-00-010572
    - mount_option_boot_efi_nosuid

    # OL08-00-010580
    - mount_option_nodev_nonroot_local_partitions

    # OL08-00-010590
    - mount_option_home_noexec

    # OL08-00-010600
    - mount_option_nodev_removable_partitions

    # OL08-00-010610
    - mount_option_noexec_removable_partitions

    # OL08-00-010620
    - mount_option_nosuid_removable_partitions

    # OL08-00-010630
    - mount_option_noexec_remote_filesystems

    # OL08-00-010640
    - mount_option_nodev_remote_filesystems

    # OL08-00-010650
    - mount_option_nosuid_remote_filesystems

    # OL08-00-010660
    - accounts_user_dot_no_world_writable_programs

    # OL08-00-010670
    - service_kdump_disabled

    # OL08-00-010671
    - sysctl_kernel_core_pattern

    # OL08-00-010672
    - service_systemd-coredump_disabled

    # OL08-00-010673
    - disable_users_coredumps

    # OL08-00-010674
    - coredump_disable_storage

    # OL08-00-010675
    - coredump_disable_backtraces

    # OL08-00-010680
    - network_configure_name_resolution

    # OL08-00-010690
    - accounts_user_home_paths_only

    # OL08-00-010700
    - dir_perms_world_writable_system_owned

    # OL08-00-010710
    - dir_perms_world_writable_system_owned_group

    # OL08-00-010720
    - accounts_user_interactive_home_directory_defined

    # OL08-00-010730
    - file_permissions_home_directories

    # OL08-00-010731
    - accounts_users_home_files_permissions

    # OL08-00-010740
    - file_groupownership_home_directories

    # OL08-00-010741
    - accounts_users_home_files_groupownership

    # OL08-00-010750
    - accounts_user_interactive_home_directory_exists

    # OL08-00-010760
    - accounts_have_homedir_login_defs

    # OL08-00-010770
    - file_permission_user_init_files

    # OL08-00-010780
    - no_files_unowned_by_user

    # OL08-00-010790
    - file_permissions_ungroupowned

    # OL08-00-010800
    - partition_for_home
    - partition_for_home.severity=medium

    # OL08-00-010820
    - gnome_gdm_disable_automatic_login

    # OL08-00-010830
    - sshd_do_not_permit_user_env
    - sshd_do_not_permit_user_env.severity=high

    # OL08-00-020000
    - account_temp_expire_date

    # OL08-00-020010, OL08-00-020011, OL08-00-020025, OL08-00-020026
    - accounts_passwords_pam_faillock_deny

    # OL08-00-020012, OL08-00-020013
    - accounts_passwords_pam_faillock_interval


    # OL08-00-020014, OL08-00-020015
    - accounts_passwords_pam_faillock_unlock_time

    # OL08-00-020016, OL08-00-020017
    - accounts_passwords_pam_faillock_dir

    # OL08-00-020018, OL08-00-020019
    - accounts_passwords_pam_faillock_silent

    # OL08-00-020020, OL08-00-020021
    - accounts_passwords_pam_faillock_audit

    # OL08-00-020022, OL08-00-020023
    - accounts_passwords_pam_faillock_deny_root

    # OL08-00-020024
    - accounts_max_concurrent_login_sessions

    # OL08-00-020027, OL08-00-020028
    - account_password_selinux_faillock_dir

    # OL08-00-020030, OL08-00-020082
    - dconf_gnome_screensaver_lock_enabled

    # OL08-00-020031
    - dconf_gnome_screensaver_lock_delay
    - var_screensaver_lock_delay=5_seconds
    
    # OL08-00-020032
    - dconf_gnome_disable_user_list

    # OL08-00-020035
    - logind_session_timeout
    - var_logind_session_timeout=15_minutes

    # OL08-00-020039
    - package_tmux_installed

    # OL08-00-020040
    - configure_tmux_lock_command
    - configure_tmux_lock_keybinding

    # OL08-00-020041
    - configure_bashrc_tmux

    # OL08-00-020042
    - no_tmux_in_shells

    # OL08-00-020043
    - vlock_installed

    # OL08-00-020050
    - dconf_gnome_lock_screen_on_smartcard_removal

    # OL08-00-020060
    - dconf_gnome_screensaver_idle_delay

    # OL08-00-020070
    - configure_tmux_lock_after_time

    # OL08-00-020080
    - dconf_gnome_screensaver_user_locks

    # OL08-00-020081
    - dconf_gnome_session_idle_user_locks

    # OL08-00-020090
    - sssd_enable_certmap

    # OL08-00-020100
    - accounts_password_pam_pwquality_password_auth

    # OL08-00-020101
    - accounts_password_pam_pwquality_system_auth

    # OL08-00-020102, OL08-00-020103, OL08-00-020104
    - accounts_password_pam_retry

    # OL08-00-020110
    - accounts_password_pam_ucredit
    - accounts_password_pam_ucredit.severity=low

    # OL08-00-020120
    - accounts_password_pam_lcredit
    - accounts_password_pam_lcredit.severity=low

    # OL08-00-020130
    - accounts_password_pam_dcredit
    - accounts_password_pam_dcredit.severity=low

    # OL08-00-020140
    - accounts_password_pam_maxclassrepeat

    # OL08-00-020150
    - accounts_password_pam_maxrepeat

    # OL08-00-020160
    - accounts_password_pam_minclass

    # OL08-00-020170
    - accounts_password_pam_difok
    - accounts_password_pam_difok.severity=low

    # OL08-00-020180
    - accounts_password_set_min_life_existing

    # OL08-00-020190
    - accounts_minimum_age_login_defs

    # OL08-00-020200
    - accounts_maximum_age_login_defs

    # OL08-00-020210
    - accounts_password_set_max_life_existing

    # OL08-00-020221
    - accounts_password_pam_pwhistory_remember_system_auth
    - accounts_password_pam_pwhistory_remember_system_auth.severity=medium

    # OL08-00-020220
    - accounts_password_pam_pwhistory_remember_password_auth
    - accounts_password_pam_pwhistory_remember_password_auth.severity=low

    # OL08-00-020230
    - accounts_password_pam_minlen

    # OL08-00-020231
    - accounts_password_minlen_login_defs

    # OL08-00-020240
    - account_unique_id

    # OL08-00-020250
    - sssd_enable_smartcards

    # OL08-00-020260
    - account_disable_post_pw_expiration
    - account_disable_inactivity_system_auth

    # OL08-00-020261
    - account_disable_inactivity_password_auth

    # OL08-00-020262
    - file_permissions_lastlog

    # OL08-00-020263
    - file_ownership_lastlog

    # OL08-00-020264
    - file_groupownership_lastlog

    # OL08-00-020270
    - account_emergency_expire_date

    # OL08-00-020280
    - accounts_password_pam_ocredit
    - accounts_password_pam_ocredit.severity=low

    # OL08-00-020290
    - sssd_offline_cred_expiration

    # OL08-00-020300
    - accounts_password_pam_dictcheck

    # OL08-00-020310
    - accounts_logon_fail_delay

    # OL08-00-020320
    - accounts_authorized_local_users

    # OL08-00-020330
    - sshd_disable_empty_passwords

    # OL08-00-020331, OL08-00-020332
    - no_empty_passwords

    # OL08-00-020340
    - display_login_attempts

    # OL08-00-020350
    - sshd_print_last_log

    # OL08-00-020351
    - accounts_umask_etc_login_defs

    # OL08-00-020352
    - accounts_umask_interactive_users

    # OL08-00-020353
    - accounts_umask_etc_bashrc
    - accounts_umask_etc_csh_cshrc
    - accounts_umask_etc_profile

    # OL08-00-030000
    - audit_rules_suid_privilege_function

    # OL08-00-030010
    - rsyslog_cron_logging

    # OL08-00-030020
    - auditd_data_retention_action_mail_acct

    # OL08-00-030030
    - postfix_client_configure_mail_alias_postmaster

    # OL08-00-030040
    - auditd_data_disk_error_action

    # OL08-00-030060
    - auditd_data_disk_full_action

    # OL08-00-030061
    - auditd_local_events

    # OL08-00-030062
    - auditd_name_format

    # OL08-00-030063
    - auditd_log_format

    # OL08-00-030070
    - file_permissions_var_log_audit

    # OL08-00-030080
    - file_ownership_var_log_audit_stig

    # OL08-00-030090
    - file_group_ownership_var_log_audit

    # OL08-00-030100
    - directory_ownership_var_log_audit

    # OL08-00-030110
    - directory_group_ownership_var_log_audit

    # OL08-00-030120
    - directory_permissions_var_log_audit

    # OL08-00-030121
    - audit_rules_immutable

    # OL08-00-030122
    - audit_immutable_login_uids

    # OL08-00-030130
    - audit_rules_usergroup_modification_shadow

    # OL08-00-030140
    - audit_rules_usergroup_modification_opasswd

    # OL08-00-030150
    - audit_rules_usergroup_modification_passwd

    # OL08-00-030160
    - audit_rules_usergroup_modification_gshadow

    # OL08-00-030170
    - audit_rules_usergroup_modification_group

    # OL08-00-030171
    - audit_rules_sudoers

    # OL08-00-030172
    - audit_rules_sudoers_d

    # OL08-00-030180
    - package_audit_installed

    # OL08-00-030181
    - service_auditd_enabled

    # OL08-00-030190
    - audit_rules_privileged_commands_su

    # OL08-00-030200
    - audit_rules_dac_modification_lremovexattr
    - audit_rules_dac_modification_removexattr
    - audit_rules_dac_modification_lsetxattr
    - audit_rules_dac_modification_fsetxattr
    - audit_rules_dac_modification_fremovexattr

    # OL08-00-030250
    - audit_rules_privileged_commands_chage

    # OL08-00-030260
    - audit_rules_execution_chcon

    # OL08-00-030270
    - audit_rules_dac_modification_setxattr

    # OL08-00-030280
    - audit_rules_privileged_commands_ssh_agent

    # OL08-00-030290
    - audit_rules_privileged_commands_passwd

    # OL08-00-030300
    - audit_rules_privileged_commands_mount

    # OL08-00-030301
    - audit_rules_privileged_commands_umount

    # OL08-00-030302
    - audit_rules_media_export

    # OL08-00-030310
    - audit_rules_privileged_commands_unix_update

    # OL08-00-030311
    - audit_rules_privileged_commands_postdrop

    # OL08-00-030312
    - audit_rules_privileged_commands_postqueue

    # OL08-00-030313
    - audit_rules_execution_semanage

    # OL08-00-030314
    - audit_rules_execution_setfiles

    # OL08-00-030315
    - audit_rules_privileged_commands_userhelper

    # OL08-00-030316
    - audit_rules_execution_setsebool

    # OL08-00-030317
    - audit_rules_privileged_commands_unix_chkpwd

    # OL08-00-030320
    - audit_rules_privileged_commands_ssh_keysign

    # OL08-00-030330
    - audit_rules_execution_setfacl

    # OL08-00-030340
    - audit_rules_privileged_commands_pam_timestamp_check

    # OL08-00-030350
    - audit_rules_privileged_commands_newgrp

    # OL08-00-030360
    - audit_rules_kernel_module_loading_init
    - audit_rules_kernel_module_loading_finit

    # OL08-00-030361
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_renameat
    - audit_rules_file_deletion_events_rmdir
    - audit_rules_file_deletion_events_unlink
    - audit_rules_file_deletion_events_unlinkat

    # OL08-00-030370
    - audit_rules_privileged_commands_gpasswd

    # OL08-00-030390
    - audit_rules_kernel_module_loading_delete

    # OL08-00-030400
    - audit_rules_privileged_commands_crontab

    # OL08-00-030410
    - audit_rules_privileged_commands_chsh

    # OL08-00-030420
    - audit_rules_unsuccessful_file_modification_truncate
    - audit_rules_unsuccessful_file_modification_openat
    - audit_rules_unsuccessful_file_modification_open
    - audit_rules_unsuccessful_file_modification_open_by_handle_at
    - audit_rules_unsuccessful_file_modification_ftruncate
    - audit_rules_unsuccessful_file_modification_creat

    # OL08-00-030480
    - audit_rules_dac_modification_chown
    - audit_rules_dac_modification_lchown
    - audit_rules_dac_modification_fchownat
    - audit_rules_dac_modification_fchown

    # OL08-00-030490
    - audit_rules_dac_modification_chmod
    - audit_rules_dac_modification_fchmod
    - audit_rules_dac_modification_fchmodat

    # OL08-00-030550
    - audit_rules_privileged_commands_sudo

    # OL08-00-030560
    - audit_rules_privileged_commands_usermod

    # OL08-00-030570
    - audit_rules_execution_chacl

    # OL08-00-030580
    - audit_rules_privileged_commands_kmod

    # OL08-00-030590
    - audit_rules_login_events_faillock

    # OL08-00-030600
    - audit_rules_login_events_lastlog

    # OL08-00-030601
    - grub2_audit_argument

    # OL08-00-030602
    - grub2_audit_backlog_limit_argument

    # OL08-00-030603
    - configure_usbguard_auditbackend

    # OL08-00-030610
    - file_permissions_etc_audit_auditd
    - file_permissions_etc_audit_rulesd

    # OL08-00-030620
    - file_audit_tools_permissions

    # OL08-00-030630
    - file_audit_tools_ownership

    # OL08-00-030640
    - file_audit_tools_group_ownership

    # OL08-00-030650
    - aide_check_audit_tools

    # OL08-00-030660
    - auditd_audispd_configure_sufficiently_large_partition

    # OL08-00-030670
    - package_rsyslog_installed

    # OL08-00-030680
    - package_rsyslog-gnutls_installed

    # OL08-00-030690
    - rsyslog_remote_loghost

    # OL08-00-030700
    - auditd_overflow_action

    # OL08-00-030710
    - rsyslog_encrypt_offload_defaultnetstreamdriver
    - rsyslog_encrypt_offload_actionsendstreamdrivermode

    # OL08-00-030720
    - rsyslog_encrypt_offload_actionsendstreamdriverauthmode

    # OL08-00-030730
    - auditd_data_retention_space_left_percentage

    # OL08-00-030731
    - auditd_data_retention_space_left_action

    # OL08-00-030740
    # remediation fails because default configuration file contains pool instead of server keyword
    - chronyd_or_ntpd_set_maxpoll
    - chronyd_server_directive

    # OL08-00-030741
    - chronyd_client_only

    # OL08-00-030742
    - chronyd_no_chronyc_network

    # OL08-00-040000
    - package_telnet-server_removed

    # OL08-00-040001
    - package_abrt_removed
    - package_abrt-libs_removed
    - package_abrt-server-info-page_removed
    - package_libreport-plugin-logger_removed

    # OL08-00-040002
    - package_sendmail_removed

    # OL08-00-040004
    - grub2_pti_argument

    # OL08-00-040010
    - package_rsh-server_removed

    # OL08-00-040020
    - kernel_module_uvcvideo_disabled

    # OL08-00-040021
    - kernel_module_atm_disabled

    # OL08-00-040022
    - kernel_module_can_disabled

    # OL08-00-040023
    - kernel_module_sctp_disabled

    # OL08-00-040024
    - kernel_module_tipc_disabled

    # OL08-00-040025
    - kernel_module_cramfs_disabled

    # OL08-00-040026
    - kernel_module_firewire-core_disabled

    # OL08-00-040030
    - configure_firewalld_ports

    # OL08-00-040070
    - service_autofs_disabled

    # OL08-00-040080
    - kernel_module_usb-storage_disabled

    # OL08-00-040090
    - configured_firewalld_default_deny

    # OL08-00-040100
    - package_firewalld_installed

    # OL08-00-040101
    - service_firewalld_enabled

    # OL08-00-040110
    - wireless_disable_interfaces

    # OL08-00-040111
    - kernel_module_bluetooth_disabled

    # OL08-00-040120
    - mount_option_dev_shm_nodev

    # OL08-00-040121
    - mount_option_dev_shm_nosuid

    # OL08-00-040122
    - mount_option_dev_shm_noexec

    # OL08-00-040123
    - mount_option_tmp_nodev

    # OL08-00-040124
    - mount_option_tmp_nosuid

    # OL08-00-040125
    - mount_option_tmp_noexec

    # OL08-00-040126
    - mount_option_var_log_nodev

    # OL08-00-040127
    - mount_option_var_log_nosuid

    # OL08-00-040128
    - mount_option_var_log_noexec

    # OL08-00-040129
    - mount_option_var_log_audit_nodev

    # OL08-00-040130
    - mount_option_var_log_audit_nosuid

    # OL08-00-040131
    - mount_option_var_log_audit_noexec

    # OL08-00-040132
    - mount_option_var_tmp_nodev

    # OL08-00-040133
    - mount_option_var_tmp_nosuid

    # OL08-00-040134
    - mount_option_var_tmp_noexec

    # OL08-00-040135
    - package_fapolicyd_installed

    # OL08-00-040136
    - service_fapolicyd_enabled

    # OL08-00-040137
    - fapolicy_default_deny

    # OL08-00-040139
    - package_usbguard_installed

    # OL08-00-040140
    - usbguard_generate_policy

    # OL08-00-040141
    - service_usbguard_enabled

    # OL08-00-040150
    - firewalld-backend

    # OL08-00-040159
    - package_openssh-server_installed

    # OL08-00-040160
    - service_sshd_enabled

    # OL08-00-040161
    - sshd_rekey_limit

    # OL08-00-040170
    - disable_ctrlaltdel_reboot

    # OL08-00-040171
    - dconf_gnome_disable_ctrlaltdel_reboot

    # OL08-00-040172
    - disable_ctrlaltdel_burstaction
    - disable_ctrlaltdel_burstaction.severity=medium

    # OL08-00-040180
    - service_debug-shell_disabled
    - service_debug-shell_disabled.severity=low

    # OL08-00-040190
    - package_tftp-server_removed

    # OL08-00-040200
    - accounts_no_uid_except_zero

    # OL08-00-040209
    - sysctl_net_ipv4_conf_default_accept_redirects

    # OL08-00-040210
    - sysctl_net_ipv6_conf_default_accept_redirects

    # OL08-00-040220
    - sysctl_net_ipv4_conf_all_send_redirects

    # OL08-00-040230
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts

    # OL08-00-040239
    - sysctl_net_ipv4_conf_all_accept_source_route

    # OL08-00-040240
    - sysctl_net_ipv6_conf_all_accept_source_route

    # OL08-00-040249
    - sysctl_net_ipv4_conf_default_accept_source_route

    # OL08-00-040250
    - sysctl_net_ipv6_conf_default_accept_source_route

    # OL08-00-040259
    - sysctl_net_ipv4_conf_all_forwarding

    # OL08-00-040260
    - sysctl_net_ipv6_conf_all_forwarding

    # OL08-00-040261
    - sysctl_net_ipv6_conf_all_accept_ra

    # OL08-00-040262
    - sysctl_net_ipv6_conf_default_accept_ra

    # OL08-00-040270
    - sysctl_net_ipv4_conf_default_send_redirects

    # OL08-00-040279
    - sysctl_net_ipv4_conf_all_accept_redirects

    # OL08-00-040280
    - sysctl_net_ipv6_conf_all_accept_redirects

    # OL08-00-040281
    - sysctl_kernel_unprivileged_bpf_disabled

    # OL08-00-040282
    - sysctl_kernel_yama_ptrace_scope

    # OL08-00-040283
    - sysctl_kernel_kptr_restrict

    # OL08-00-040284
    - sysctl_user_max_user_namespaces

    # OL08-00-040285
    - sysctl_net_ipv4_conf_all_rp_filter

    # OL08-00-040286
    - sysctl_net_core_bpf_jit_harden

    # OL08-00-040290
    - postfix_prevent_unrestricted_relay

    # OL08-00-040300
    - aide_verify_ext_attributes

    # OL08-00-040310
    - aide_verify_acls

    # OL08-00-040320
    - xwindows_remove_packages

    # OL08-00-040321
    - xwindows_runlevel_target

    # OL08-00-040330
    - network_sniffer_disabled

    # OL08-00-040340
    - sshd_disable_x11_forwarding

    # OL08-00-040341
    - sshd_x11_use_localhost

    # OL08-00-040342
    - sshd_use_approved_kex_ordered_stig

    # OL08-00-040350
    - tftpd_uses_secure_mode
    - tftpd_uses_secure_mode.severity=medium

    # OL08-00-040360
    - package_vsftpd_removed

    # OL08-00-040370
    - package_gssproxy_removed

    # OL08-00-040380
    - package_iprutils_removed

    # OL08-00-040390
    - package_tuned_removed

    # OL08-00-040400
    - selinux_user_login_roles

    # OL08-00-010163
    - package_krb5-server_removed
