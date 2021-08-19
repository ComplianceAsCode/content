documentation_complete: true

metadata:
    version: V1R3
    SMEs:
        - ggbecker

reference: https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: 'DISA STIG for Red Hat Enterprise Linux 8'

description: |-
    This profile contains configuration checks that align to the
    DISA STIG for Red Hat Enterprise Linux 8 V1R3.

    In addition to being applicable to Red Hat Enterprise Linux 8, DISA recognizes this
    configuration baseline as applicable to the operating system tier of
    Red Hat technologies that are based on Red Hat Enterprise Linux 8, such as:

    - Red Hat Enterprise Linux Server
    - Red Hat Enterprise Linux Workstation and Desktop
    - Red Hat Enterprise Linux for HPC
    - Red Hat Storage
    - Red Hat Containers with a Red Hat Enterprise Linux 8 image

selections:
    ### Variables
    - var_rekey_limit_size=1G
    - var_rekey_limit_time=1hour
    - var_accounts_user_umask=077
    - var_password_pam_difok=8
    - var_password_pam_maxrepeat=3
    - var_sshd_disable_compression=no
    - var_password_hashing_algorithm=SHA512
    - var_password_pam_maxclassrepeat=4
    - var_password_pam_minclass=4
    - var_accounts_minimum_age_login_defs=1
    - var_accounts_max_concurrent_login_sessions=10
    - var_password_pam_remember=5
    - var_password_pam_remember_control_flag=required
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
    - sshd_approved_macs=stig
    - sshd_approved_ciphers=stig
    - sshd_idle_timeout_value=10_minutes
    - var_accounts_authorized_local_users_regex=rhel8
    - var_accounts_passwords_pam_faillock_deny=3
    - var_accounts_passwords_pam_faillock_fail_interval=900
    - var_accounts_passwords_pam_faillock_unlock_time=never
    - var_ssh_client_rekey_limit_size=1G
    - var_ssh_client_rekey_limit_time=1hour
    - var_accounts_fail_delay=4
    - var_account_disable_post_pw_expiration=35
    - var_auditd_action_mail_acct=root
    - var_time_service_set_maxpoll=18_hours
    - var_accounts_maximum_age_login_defs=60
    - var_auditd_space_left_percentage=25pc
    - var_auditd_space_left_action=email
    - var_auditd_disk_error_action=halt
    - var_auditd_max_log_file_action=syslog
    - var_auditd_disk_full_action=halt

    ### Enable / Configure FIPS
    - enable_fips_mode
    - var_system_crypto_policy=fips
    - configure_crypto_policy
    - configure_bind_crypto_policy
    - configure_libreswan_crypto_policy
    - configure_kerberos_crypto_policy
    - enable_dracut_fips_module

    ### Rules:
    # RHEL-08-010000
    - installed_OS_is_vendor_supported

    # RHEL-08-010001
    - package_mcafeetp_installed
    - agent_mfetpd_running

    # RHEL-08-010010
    - security_patches_up_to_date

    # RHEL-08-010020
    - sysctl_crypto_fips_enabled

    # RHEL-08-010030
    - encrypt_partitions

    # RHEL-08-010040
    - sshd_enable_warning_banner

    # RHEL-08-010049
    - dconf_gnome_banner_enabled

    # RHEL-08-010050
    - dconf_gnome_login_banner_text

    # RHEL-08-010060
    - banner_etc_issue

    # RHEL-08-010070
    - rsyslog_remote_access_monitoring

    # RHEL-08-010090

    # RHEL-08-010100

    # RHEL-08-010110
    - set_password_hashing_algorithm_logindefs

    # RHEL-08-010120
    - accounts_password_all_shadowed_sha512

    # RHEL-08-010130
    - accounts_password_pam_unix_rounds_password_auth

    # RHEL-08-010131
    - accounts_password_pam_unix_rounds_system_auth

    # RHEL-08-010140
    - grub2_uefi_password

    # RHEL-08-010141
    - grub2_uefi_admin_username

    # RHEL-08-010149
    - grub2_admin_username

    # RHEL-08-010150
    - grub2_password

    # RHEL-08-010151
    - require_singleuser_auth

    # RHEL-08-010152
    - require_emergency_target_auth

    # RHEL-08-010160
    - set_password_hashing_algorithm_systemauth

    # RHEL-08-010161
    - kerberos_disable_no_keytab

    # RHEL-08-010162
    - package_krb5-workstation_removed

    # RHEL-08-010170
    - selinux_state

    # RHEL-08-010171
    - package_policycoreutils_installed

    # RHEL-08-010180

    # RHEL-08-010190
    - dir_perms_world_writable_sticky_bits

    # RHEL-08-010200
    - sshd_set_keepalive_0

    # RHEL-08-010201
    - sshd_set_idle_timeout

    # RHEL-08-010210
    - file_permissions_var_log_messages

    # RHEL-08-010220
    - file_owner_var_log_messages

    # RHEL-08-010230
    - file_groupowner_var_log_messages

    # RHEL-08-010240
    - file_permissions_var_log

    # RHEL-08-010250
    - file_owner_var_log

    # RHEL-08-010260
    - file_groupowner_var_log

    # *** SHARED *** #
    # RHEL-08-010290 && RHEL-08-010291
    # *** SHARED *** #
    - configure_ssh_crypto_policy

    # RHEL-08-010290
    - harden_sshd_macs_openssh_conf_crypto_policy
    - harden_sshd_macs_opensshserver_conf_crypto_policy

    # RHEL-08-010291
    - harden_sshd_ciphers_openssh_conf_crypto_policy
    - harden_sshd_ciphers_opensshserver_conf_crypto_policy

    # RHEL-08-010292
    - sshd_use_strong_rng

    # RHEL-08-010293
    - configure_openssl_crypto_policy

    # RHEL-08-010294
    - configure_openssl_tls_crypto_policy

    # RHEL-08-010295
    - configure_gnutls_tls_crypto_policy

    # RHEL-08-010300
    - file_permissions_binary_dirs

    # RHEL-08-010310
    - file_ownership_binary_dirs

    # RHEL-08-010320
    - file_groupownership_system_commands_dirs

    # RHEL-08-010330
    - file_permissions_library_dirs

    # RHEL-08-010340
    - file_ownership_library_dirs

    # RHEL-08-010350
    - root_permissions_syslibrary_files
    - dir_group_ownership_library_dirs

    # RHEL-08-010360
    - package_aide_installed
    - aide_scan_notification

    # RHEL-08-010370
    - ensure_gpgcheck_globally_activated

    # RHEL-08-010371
    - ensure_gpgcheck_local_packages

    # RHEL-08-010372
    - sysctl_kernel_kexec_load_disabled

    # RHEL-08-010373
    - sysctl_fs_protected_symlinks

    # RHEL-08-010374
    - sysctl_fs_protected_hardlinks

    # RHEL-08-010375
    - sysctl_kernel_dmesg_restrict

    # RHEL-08-010376
    - sysctl_kernel_perf_event_paranoid

    # RHEL-08-010380
    - sudo_remove_nopasswd

    # RHEL-08-010381
    - sudo_remove_no_authenticate

    # RHEL-08-010382
    - sudo_restrict_privilege_elevation_to_authorized

    # RHEL-08-010383
    - sudoers_validate_passwd

    # RHEL-08-010384
    - sudo_require_reauthentication
    - var_sudo_timestamp_timeout=always_prompt

    # RHEL-08-010390
    - install_smartcard_packages

    # RHEL-08-010400

    # RHEL-08-010410
    - package_opensc_installed

    # RHEL-08-010420
    - bios_enable_execution_restrictions

    # RHEL-08-010421
    - grub2_page_poison_argument

    # RHEL-08-010422
    - grub2_vsyscall_argument

    # RHEL-08-010423
    - grub2_slub_debug_argument

    # RHEL-08-010430
    - sysctl_kernel_randomize_va_space

    # RHEL-08-010440
    - clean_components_post_updating

    # RHEL-08-010450
    - selinux_policytype

    # RHEL-08-010460
    - no_host_based_files

    # RHEL-08-010470
    - no_user_host_based_files

    # RHEL-08-010471
    - service_rngd_enabled

    # RHEL-08-010472
    - package_rng-tools_installed

    # RHEL-08-010480
    - file_permissions_sshd_pub_key

    # RHEL-08-010490
    - file_permissions_sshd_private_key

    # RHEL-08-010500
    - sshd_enable_strictmodes

    # RHEL-08-010510
    - sshd_disable_compression

    # RHEL-08-010520
    - sshd_disable_user_known_hosts

    # RHEL-08-010521
    - sshd_disable_kerb_auth

    # RHEL-08-010522
    - sshd_disable_gssapi_auth

    # RHEL-08-010540
    - partition_for_var

    # RHEL-08-010541
    - partition_for_var_log

    # RHEL-08-010542
    - partition_for_var_log_audit

    # RHEL-08-010543
    - partition_for_tmp

    # RHEL-08-010544
    ### NOTE: Will probably show up in V1R3 - Q3 of 21'
    - partition_for_var_tmp

    # RHEL-08-010550
    - sshd_disable_root_login

    # RHEL-08-010560
    - service_auditd_enabled

    # RHEL-08-010561
    - service_rsyslog_enabled

    # RHEL-08-010570
    - mount_option_home_nosuid

    # RHEL-08-010571
    - mount_option_boot_nosuid

    # RHEL-08-010580
    - mount_option_nodev_nonroot_local_partitions

    # RHEL-08-010590
    - mount_option_home_noexec

    # RHEL-08-010600
    - mount_option_nodev_removable_partitions

    # RHEL-08-010610
    - mount_option_noexec_removable_partitions

    # RHEL-08-010620
    - mount_option_nosuid_removable_partitions

    # RHEL-08-010630
    - mount_option_noexec_remote_filesystems

    # RHEL-08-010640
    - mount_option_nodev_remote_filesystems

    # RHEL-08-010650
    - mount_option_nosuid_remote_filesystems

    # RHEL-08-010660
    - accounts_user_dot_no_world_writable_programs

    # RHEL-08-010670
    - service_kdump_disabled

    # RHEL-08-010671
    - sysctl_kernel_core_pattern

    # RHEL-08-010672
    - service_systemd-coredump_disabled

    # RHEL-08-010673
    - disable_users_coredumps

    # RHEL-08-010674
    - coredump_disable_storage

    # RHEL-08-010675
    - coredump_disable_backtraces

    # RHEL-08-010680
    - network_configure_name_resolution

    # RHEL-08-010690
    - accounts_user_home_paths_only

    # RHEL-08-010700
    - dir_perms_world_writable_root_owned

    # RHEL-08-010710

    # RHEL-08-010720
    - accounts_user_interactive_home_directory_defined

    # RHEL-08-010730
    - file_permissions_home_directories

    # RHEL-08-010740
    - file_groupownership_home_directories

    # RHEL-08-010750
    - accounts_user_interactive_home_directory_exists

    # RHEL-08-010760
    - accounts_have_homedir_login_defs

    # RHEL-08-010770
    - file_permission_user_init_files

    # RHEL-08-010780
    - no_files_unowned_by_user

    # RHEL-08-010790
    - file_permissions_ungroupowned

    # RHEL-08-010800
    - partition_for_home

    # RHEL-08-010820
    - gnome_gdm_disable_automatic_login

    # RHEL-08-010830
    - sshd_do_not_permit_user_env

    # RHEL-08-020000
    - account_temp_expire_date

    # RHEL-08-020010
    - accounts_passwords_pam_faillock_deny

    # RHEL-08-020011

    # RHEL-08-020012
    - accounts_passwords_pam_faillock_interval

    # RHEL-08-020013

    # RHEL-08-020014
    - accounts_passwords_pam_faillock_unlock_time

    # RHEL-08-020015

    # RHEL-08-020016

    # RHEL-08-020017

    # RHEL-08-020018

    # RHEL-08-020019

    # RHEL-08-020020

    # RHEL-08-020021

    # RHEL-08-020022
    - accounts_passwords_pam_faillock_deny_root

    # RHEL-08-020023

    # RHEL-08-020024
    - accounts_max_concurrent_login_sessions

    # RHEL-08-020030
    - dconf_gnome_screensaver_lock_enabled

    # RHEL-08-020039
    - package_tmux_installed

    # RHEL-08-020040
    - configure_tmux_lock_command

    # RHEL-08-020041
    - configure_bashrc_exec_tmux

    # RHEL-08-020042
    - no_tmux_in_shells

    # RHEL-08-020050
    - dconf_gnome_lock_screen_on_smartcard_removal

    # RHEL-08-020060
    - dconf_gnome_screensaver_idle_delay

    # RHEL-08-020070
    - configure_tmux_lock_after_time

    # RHEL-08-020080

    # RHEL-08-020090
    - sssd_enable_certmap

    # RHEL-08-020100
    - accounts_password_pam_retry

    # RHEL-08-020110
    - accounts_password_pam_ucredit

    # RHEL-08-020120
    - accounts_password_pam_lcredit

    # RHEL-08-020130
    - accounts_password_pam_dcredit

    # RHEL-08-020140
    - accounts_password_pam_maxclassrepeat

    # RHEL-08-020150
    - accounts_password_pam_maxrepeat

    # RHEL-08-020160
    - accounts_password_pam_minclass

    # RHEL-08-020170
    - accounts_password_pam_difok

    # RHEL-08-020180
    - accounts_password_set_min_life_existing

    # RHEL-08-020190
    - accounts_minimum_age_login_defs

    # RHEL-08-020200
    - accounts_maximum_age_login_defs

    # RHEL-08-020210
    - accounts_password_set_max_life_existing

    # RHEL-08-020220
    - accounts_password_pam_pwhistory_remember_system_auth
    - accounts_password_pam_pwhistory_remember_password_auth

    # RHEL-08-020230
    - accounts_password_pam_minlen

    # RHEL-08-020231
    - accounts_password_minlen_login_defs

    # RHEL-08-020240
    - account_unique_id

    # RHEL-08-020250
    - sssd_enable_smartcards

    # RHEL-08-020260
    - account_disable_post_pw_expiration

    # RHEL-08-020270
    - account_emergency_expire_date

    # RHEL-08-020280
    - accounts_password_pam_ocredit

    # RHEL-08-020290
    - sssd_offline_cred_expiration

    # RHEL-08-020300
    - accounts_password_pam_dictcheck

    # RHEL-08-020310
    - accounts_logon_fail_delay

    # RHEL-08-020320
    - accounts_authorized_local_users

    # RHEL-08-020330
    - sshd_disable_empty_passwords

    # RHEL-08-020331
    - no_empty_passwords

    # RHEL-08-020332

    # RHEL-08-020340
    - display_login_attempts

    # RHEL-08-020350
    - sshd_print_last_log

    # RHEL-08-020351
    - accounts_umask_etc_login_defs

    # RHEL-08-020352
    - accounts_umask_interactive_users

    # RHEL-08-020353
    - accounts_umask_etc_bashrc

    # RHEL-08-030000
    - audit_rules_suid_privilege_function

    # RHEL-08-030010
    - rsyslog_cron_logging

    # RHEL-08-030020
    - auditd_data_retention_action_mail_acct

    # RHEL-08-030030
    - postfix_client_configure_mail_alias

    # RHEL-08-030040
    - auditd_data_disk_error_action

    # RHEL-08-030050
    - auditd_data_retention_max_log_file_action

    # RHEL-08-030060
    - auditd_data_disk_full_action

    # RHEL-08-030061
    - auditd_local_events

    # RHEL-08-030062
    - auditd_name_format

    # RHEL-08-030063
    - auditd_log_format

    # RHEL-08-030070
    - file_permissions_var_log_audit

    # RHEL-08-030080
    - file_ownership_var_log_audit_stig

    # RHEL-08-030090
    - file_group_ownership_var_log_audit

    # RHEL-08-030100
    - directory_ownership_var_log_audit

    # RHEL-08-030110
    - directory_group_ownership_var_log_audit

    # RHEL-08-030120
    - directory_permissions_var_log_audit

    # *** NOTE *** #
    # Audit rules are currently under review as to how best to approach
    # them. We are working with DISA and our internal audit experts to
    # provide a final solution soon.
    # ************ #

    # RHEL-08-030121
    - audit_rules_immutable

    # RHEL-08-030122
    - audit_immutable_login_uids

    # RHEL-08-030130
    - audit_rules_usergroup_modification_shadow

    # RHEL-08-030140
    - audit_rules_usergroup_modification_opasswd

    # RHEL-08-030150
    - audit_rules_usergroup_modification_passwd

    # RHEL-08-030160
    - audit_rules_usergroup_modification_gshadow

    # RHEL-08-030170
    - audit_rules_usergroup_modification_group

    # RHEL-08-030171
    - audit_rules_sudoers

    # RHEL-08-030172
    - audit_rules_sudoers_d

    # RHEL-08-030180
    - package_audit_installed

    # RHEL-08-030181
    - service_auditd_enabled

    # RHEL-08-030190
    - audit_rules_privileged_commands_su

    # RHEL-08-030200
    - audit_rules_dac_modification_lremovexattr

    # RHEL-08-030210
    - audit_rules_dac_modification_removexattr

    # RHEL-08-030220
    - audit_rules_dac_modification_lsetxattr

    # RHEL-08-030230
    - audit_rules_dac_modification_fsetxattr

    # RHEL-08-030240
    - audit_rules_dac_modification_fremovexattr

    # RHEL-08-030250
    - audit_rules_privileged_commands_chage

    # RHEL-08-030260
    - audit_rules_execution_chcon

    # RHEL-08-030270
    - audit_rules_dac_modification_setxattr

    # RHEL-08-030280
    - audit_rules_privileged_commands_ssh_agent

    # RHEL-08-030290
    - audit_rules_privileged_commands_passwd

    # RHEL-08-030300
    - audit_rules_privileged_commands_mount

    # RHEL-08-030301
    - audit_rules_privileged_commands_umount

    # RHEL-08-030302
    - audit_rules_media_export

    # RHEL-08-030310
    - audit_rules_privileged_commands_unix_update

    # RHEL-08-030311
    - audit_rules_privileged_commands_postdrop

    # RHEL-08-030312
    - audit_rules_privileged_commands_postqueue

    # RHEL-08-030313
    - audit_rules_execution_semanage

    # RHEL-08-030314
    - audit_rules_execution_setfiles

    # RHEL-08-030315
    - audit_rules_privileged_commands_userhelper

    # RHEL-08-030316
    - audit_rules_execution_setsebool

    # RHEL-08-030317
    - audit_rules_privileged_commands_unix_chkpwd

    # RHEL-08-030320
    - audit_rules_privileged_commands_ssh_keysign

    # RHEL-08-030330
    - audit_rules_execution_setfacl

    # RHEL-08-030340
    - audit_rules_privileged_commands_pam_timestamp_check

    # RHEL-08-030350
    - audit_rules_privileged_commands_newgrp

    # RHEL-08-030360
    - audit_rules_kernel_module_loading_init

    # RHEL-08-030361
    - audit_rules_file_deletion_events_rename

    # RHEL-08-030362
    - audit_rules_file_deletion_events_renameat

    # RHEL-08-030363
    - audit_rules_file_deletion_events_rmdir

    # RHEL-08-030364
    - audit_rules_file_deletion_events_unlink

    # RHEL-08-030365
    - audit_rules_file_deletion_events_unlinkat

    # RHEL-08-030370
    - audit_rules_privileged_commands_gpasswd

    # RHEL-08-030380
    - audit_rules_kernel_module_loading_finit

    # RHEL-08-030390
    - audit_rules_kernel_module_loading_delete

    # RHEL-08-030400
    - audit_rules_privileged_commands_crontab

    # RHEL-08-030410
    - audit_rules_privileged_commands_chsh

    # RHEL-08-030420
    - audit_rules_unsuccessful_file_modification_truncate

    # RHEL-08-030430
    - audit_rules_unsuccessful_file_modification_openat

    # RHEL-08-030440
    - audit_rules_unsuccessful_file_modification_open

    # RHEL-08-030450
    - audit_rules_unsuccessful_file_modification_open_by_handle_at

    # RHEL-08-030460
    - audit_rules_unsuccessful_file_modification_ftruncate

    # RHEL-08-030470
    - audit_rules_unsuccessful_file_modification_creat

    # RHEL-08-030480
    - audit_rules_dac_modification_chown

    # RHEL-08-030490
    - audit_rules_dac_modification_chmod

    # RHEL-08-030500
    - audit_rules_dac_modification_lchown

    # RHEL-08-030510
    - audit_rules_dac_modification_fchownat

    # RHEL-08-030520
    - audit_rules_dac_modification_fchown

    # RHEL-08-030530
    - audit_rules_dac_modification_fchmodat

    # RHEL-08-030540
    - audit_rules_dac_modification_fchmod

    # RHEL-08-030550
    - audit_rules_privileged_commands_sudo

    # RHEL-08-030560
    - audit_rules_privileged_commands_usermod

    # RHEL-08-030570
    - audit_rules_execution_chacl

    # RHEL-08-030580
    - audit_rules_privileged_commands_kmod

    # RHEL-08-030590
    # This one needs to be updated to use /var/log/faillock, but first RHEL-08-020017 should be
    # implemented as it is the one that configures a different path for the events of failing locks
    # - audit_rules_login_events_faillock

    # RHEL-08-030600
    - audit_rules_login_events_lastlog

    # RHEL-08-030601
    - grub2_audit_argument

    # RHEL-08-030602
    - grub2_audit_backlog_limit_argument

    # RHEL-08-030603
    - configure_usbguard_auditbackend

    # RHEL-08-030610
    - file_permissions_etc_audit_auditd
    - file_permissions_etc_audit_rulesd

    # RHEL-08-030620

    # RHEL-08-030630

    # RHEL-08-030640

    # RHEL-08-030650
    - aide_check_audit_tools

    # RHEL-08-030660
    - auditd_audispd_configure_sufficiently_large_partition

    # RHEL-08-030670
    - package_rsyslog_installed

    # RHEL-08-030680
    - package_rsyslog-gnutls_installed

    # RHEL-08-030690
    - rsyslog_remote_loghost

    # RHEL-08-030700
    - auditd_overflow_action

    # RHEL-08-030710
    - rsyslog_encrypt_offload_defaultnetstreamdriver
    - rsyslog_encrypt_offload_actionsendstreamdrivermode

    # RHEL-08-030720
    - rsyslog_encrypt_offload_actionsendstreamdriverauthmode

    # RHEL-08-030730
    - auditd_data_retention_space_left_percentage

    # RHEL-08-030731
    - auditd_data_retention_space_left_action

    # RHEL-08-030740
    # remediation fails because default configuration file contains pool instead of server keyword
    - chronyd_or_ntpd_set_maxpoll

    # RHEL-08-030741
    - chronyd_client_only

    # RHEL-08-030742
    - chronyd_no_chronyc_network

    # RHEL-08-040000
    - package_telnet-server_removed

    # RHEL-08-040001
    - package_abrt_removed
    - package_abrt-addon-ccpp_removed
    - package_abrt-addon-kerneloops_removed
    - package_abrt-addon-python_removed
    - package_abrt-cli_removed
    - package_abrt-plugin-logger_removed
    - package_abrt-plugin-rhtsupport_removed
    - package_abrt-plugin-sosreport_removed

    # RHEL-08-040002
    - package_sendmail_removed

    # RHEL-08-040003
    ### NOTE: Will be removed in V1R2, merged into RHEL-08-040370

    # RHEL-08-040004
    - grub2_pti_argument

    # RHEL-08-040010
    - package_rsh-server_removed

    # RHEL-08-040020

    # RHEL-08-040021
    - kernel_module_atm_disabled

    # RHEL-08-040022
    - kernel_module_can_disabled

    # RHEL-08-040023
    - kernel_module_sctp_disabled

    # RHEL-08-040024
    - kernel_module_tipc_disabled

    # RHEL-08-040025
    - kernel_module_cramfs_disabled

    # RHEL-08-040026
    - kernel_module_firewire-core_disabled

    # RHEL-08-040030
    - configure_firewalld_ports

    # RHEL-08-040060
    ### NOTE: Will be removed in V1R2

    # RHEL-08-040070
    - service_autofs_disabled

    # RHEL-08-040080
    - kernel_module_usb-storage_disabled

    # RHEL-08-040090

    # RHEL-08-040100
    - package_firewalld_installed

    # RHEL-08-040101
    - service_firewalld_enabled

    # RHEL-08-040110
    - wireless_disable_interfaces

    # RHEL-08-040111
    - kernel_module_bluetooth_disabled

    # RHEL-08-040120
    - mount_option_dev_shm_nodev

    # RHEL-08-040121
    - mount_option_dev_shm_nosuid

    # RHEL-08-040122
    - mount_option_dev_shm_noexec

    # RHEL-08-040123
    - mount_option_tmp_nodev

    # RHEL-08-040124
    - mount_option_tmp_nosuid

    # RHEL-08-040125
    - mount_option_tmp_noexec

    # RHEL-08-040126
    - mount_option_var_log_nodev

    # RHEL-08-040127
    - mount_option_var_log_nosuid

    # RHEL-08-040128
    - mount_option_var_log_noexec

    # RHEL-08-040129
    - mount_option_var_log_audit_nodev

    # RHEL-08-040130
    - mount_option_var_log_audit_nosuid

    # RHEL-08-040131
    - mount_option_var_log_audit_noexec

    # RHEL-08-040132
    - mount_option_var_tmp_nodev

    # RHEL-08-040133
    - mount_option_var_tmp_nosuid

    # RHEL-08-040134
    - mount_option_var_tmp_noexec

    # RHEL-08-040135
    - package_fapolicyd_installed

    # RHEL-08-040136
    - service_fapolicyd_enabled

    # RHEL-08-040139
    - package_usbguard_installed

    # RHEL-08-040140
    - usbguard_generate_policy

    # RHEL-08-040141
    - service_usbguard_enabled

    # RHEL-08-040150

    # RHEL-08-040159
    - package_openssh-server_installed

    # RHEL-08-040160
    - service_sshd_enabled

    # RHEL-08-040161
    - sshd_rekey_limit

    # RHEL-08-040170
    - disable_ctrlaltdel_reboot

    # RHEL-08-040171
    - dconf_gnome_disable_ctrlaltdel_reboot

    # RHEL-08-040172
    - disable_ctrlaltdel_burstaction

    # RHEL-08-040180
    - service_debug-shell_disabled

    # RHEL-08-040190
    - package_tftp-server_removed

    # RHEL-08-040200
    - accounts_no_uid_except_zero

    # RHEL-08-040209
    - sysctl_net_ipv4_conf_default_accept_redirects

    # RHEL-08-040210
    - sysctl_net_ipv6_conf_default_accept_redirects

    # RHEL-08-040220
    - sysctl_net_ipv4_conf_all_send_redirects

    # RHEL-08-040230
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts

    # RHEL-08-040239
    - sysctl_net_ipv4_conf_all_accept_source_route

    # RHEL-08-040240
    - sysctl_net_ipv6_conf_all_accept_source_route

    # RHEL-08-040249
    - sysctl_net_ipv4_conf_default_accept_source_route

    # RHEL-08-040250
    - sysctl_net_ipv6_conf_default_accept_source_route

    # RHEL-08-040260
    - sysctl_net_ipv4_ip_forward

    # RHEL-08-040261
    - sysctl_net_ipv6_conf_all_accept_ra

    # RHEL-08-040262
    - sysctl_net_ipv6_conf_default_accept_ra

    # RHEL-08-040270
    - sysctl_net_ipv4_conf_default_send_redirects

    # RHEL-08-040279
    - sysctl_net_ipv4_conf_all_accept_redirects

    # RHEL-08-040280
    - sysctl_net_ipv6_conf_all_accept_redirects

    # RHEL-08-040281
    - sysctl_kernel_unprivileged_bpf_disabled

    # RHEL-08-040282
    - sysctl_kernel_yama_ptrace_scope

    # RHEL-08-040283
    - sysctl_kernel_kptr_restrict

    # RHEL-08-040284
    - sysctl_user_max_user_namespaces

    # RHEL-08-040285
    - sysctl_net_ipv4_conf_all_rp_filter

    # RHEL-08-040286
    - sysctl_net_core_bpf_jit_harden

    # RHEL-08-040290
    # /etc/postfix/main.cf does not exist on default installation resulting in error during remediation
    # there needs to be a new platform check to identify when postfix is installed or not
    # - postfix_prevent_unrestricted_relay

    # RHEL-08-040300
    - aide_verify_ext_attributes

    # RHEL-08-040310
    - aide_verify_acls

    # RHEL-08-040320
    - xwindows_remove_packages

    # RHEL-08-040330
    - network_sniffer_disabled

    # RHEL-08-040340
    - sshd_disable_x11_forwarding

    # RHEL-08-040341
    - sshd_x11_use_localhost

    # RHEL-08-040350
    - tftpd_uses_secure_mode

    # RHEL-08-040360
    - package_vsftpd_removed

    # RHEL-08-040370
    - package_gssproxy_removed

    # RHEL-08-040380
    - package_iprutils_removed

    # RHEL-08-040390
    - package_tuned_removed
