description: 'This is a draft profile for experimental purposes.


    The HIPAA Security Rule establishes U.S. national standards to protect individuals''s

    electronic personal health information that is created, received, used, or

    maintained by a covered entity. The Security Rule requires appropriate

    administrative, physical and technical safeguards to ensure the

    confidentiality, integrity, and security of electronic protected health

    information.


    This draft profile configures Red Hat Enterprise Linux 10 to the HIPAA Security

    Rule identified for securing of electronic protected health information.

    Use of this profile in no way guarantees or makes claims against legal compliance
    against the HIPAA Security Rule(s).'
extends: null
hidden: ''
status: ''
metadata:
    SMEs:
    - jjaswanson4
reference: https://www.hhs.gov/hipaa/for-professionals/index.html
selections:
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
- audit_rules_execution_chcon
- audit_rules_execution_restorecon
- audit_rules_execution_semanage
- audit_rules_execution_setsebool
- audit_rules_file_deletion_events_rename
- audit_rules_file_deletion_events_renameat
- audit_rules_file_deletion_events_rmdir
- audit_rules_file_deletion_events_unlink
- audit_rules_file_deletion_events_unlinkat
- audit_rules_immutable
- audit_rules_kernel_module_loading_delete
- audit_rules_kernel_module_loading_finit
- audit_rules_kernel_module_loading_init
- audit_rules_login_events_faillock
- audit_rules_login_events_lastlog
- audit_rules_login_events_tallylog
- audit_rules_mac_modification_etc_selinux
- audit_rules_mac_modification_usr_share
- audit_rules_media_export
- audit_rules_networkconfig_modification
- audit_rules_privileged_commands_chage
- audit_rules_privileged_commands_chsh
- audit_rules_privileged_commands_crontab
- audit_rules_privileged_commands_gpasswd
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
- audit_rules_privileged_commands_unix2_chkpwd
- audit_rules_privileged_commands_unix_chkpwd
- audit_rules_privileged_commands_userhelper
- audit_rules_session_events
- audit_rules_sysadmin_actions
- audit_rules_system_shutdown
- audit_rules_time_adjtimex
- audit_rules_time_clock_settime
- audit_rules_time_settimeofday
- audit_rules_time_stime
- audit_rules_time_watch_localtime
- audit_rules_unsuccessful_file_modification_creat
- audit_rules_unsuccessful_file_modification_ftruncate
- audit_rules_unsuccessful_file_modification_open
- audit_rules_unsuccessful_file_modification_open_by_handle_at
- audit_rules_unsuccessful_file_modification_open_by_handle_at_o_creat
- audit_rules_unsuccessful_file_modification_open_by_handle_at_o_trunc_write
- audit_rules_unsuccessful_file_modification_open_by_handle_at_rule_order
- audit_rules_unsuccessful_file_modification_open_o_creat
- audit_rules_unsuccessful_file_modification_open_o_trunc_write
- audit_rules_unsuccessful_file_modification_open_rule_order
- audit_rules_unsuccessful_file_modification_openat
- audit_rules_unsuccessful_file_modification_openat_o_creat
- audit_rules_unsuccessful_file_modification_openat_o_trunc_write
- audit_rules_unsuccessful_file_modification_openat_rule_order
- audit_rules_unsuccessful_file_modification_rename
- audit_rules_unsuccessful_file_modification_renameat
- audit_rules_unsuccessful_file_modification_truncate
- audit_rules_unsuccessful_file_modification_unlink
- audit_rules_unsuccessful_file_modification_unlinkat
- audit_rules_usergroup_modification_group
- audit_rules_usergroup_modification_gshadow
- audit_rules_usergroup_modification_opasswd
- audit_rules_usergroup_modification_passwd
- audit_rules_usergroup_modification_shadow
- auditd_data_retention_action_mail_acct
- auditd_data_retention_admin_space_left_action
- auditd_data_retention_flush
- auditd_data_retention_max_log_file_action
- auditd_data_retention_max_log_file_action_stig
- auditd_data_retention_space_left_action
- configure_crypto_policy
- configure_ssh_crypto_policy
- dconf_db_up_to_date
- disable_ctrlaltdel_burstaction
- disable_ctrlaltdel_reboot
- disable_host_auth
- enable_authselect
- encrypt_partitions
- ensure_gpgcheck_globally_activated
- ensure_gpgcheck_local_packages
- ensure_gpgcheck_never_disabled
- ensure_gpgcheck_repo_metadata
- ensure_redhat_gpgkey_installed
- file_groupowner_grub2_cfg
- file_groupowner_user_cfg
- file_owner_grub2_cfg
- file_owner_user_cfg
- file_permissions_grub2_cfg
- file_permissions_user_cfg
- grub2_admin_username
- grub2_audit_argument
- grub2_disable_interactive_boot
- grub2_enable_selinux
- grub2_nousb_argument
- grub2_password
- grub2_uefi_password
- kernel_module_usb-storage_disabled
- libreswan_approved_tunnels
- no_direct_root_logins
- no_empty_passwords
- package_audit_installed
- package_cron_installed
- package_rsyslog_installed
- package_telnet-server_removed
- package_telnet_removed
- partition_for_var_log_audit
- require_emergency_target_auth
- require_singleuser_auth
- restrict_serial_port_logins
- rpm_verify_hashes
- rpm_verify_permissions
- rsyslog_remote_loghost
- sebool_selinuxuser_execheap
- sebool_selinuxuser_execmod
- sebool_selinuxuser_execstack
- securetty_root_login_console_only
- selinux_confinement_of_daemons
- selinux_policytype
- selinux_state
- service_auditd_enabled
- service_autofs_disabled
- service_cron_enabled
- service_crond_enabled
- service_debug-shell_disabled
- service_kdump_disabled
- service_rexec_disabled
- service_rlogin_disabled
- service_rsh_disabled
- service_rsyslog_enabled
- service_telnet_disabled
- sshd_disable_compression
- sshd_disable_empty_passwords
- sshd_disable_rhosts_rsa
- sshd_disable_root_login
- sshd_disable_user_known_hosts
- sshd_do_not_permit_user_env
- sshd_enable_strictmodes
- sshd_enable_warning_banner
- sshd_set_keepalive
- sshd_set_keepalive_0
- sshd_use_directory_configuration
- sshd_use_priv_separation
- sysctl_fs_suid_dumpable
- sysctl_kernel_dmesg_restrict
- sysctl_kernel_exec_shield
- sysctl_kernel_randomize_va_space
- use_kerberos_security_all_exports
- var_audit_failure_mode=panic
- var_selinux_policy_name=targeted
- var_selinux_state=enforcing
- var_sshd_set_keepalive=1
- var_authselect_profile=sssd
unselected_groups: []
platforms: !!set {}
cpe_names: !!set {}
platform: null
filter_rules: ''
policies:
- hipaa
title: Health Insurance Portability and Accountability Act (HIPAA)
documentation_complete: true
