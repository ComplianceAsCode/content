documentation_complete: True

metadata:
    SMEs:
        - jjaswanson4
        - carlosmmatos

reference: https://www.hhs.gov/hipaa/for-professionals/index.html

title: 'Health Insurance Portability and Accountability Act (HIPAA)'

description: |-
    The HIPAA Security Rule establishes U.S. national standards to protect individuals’
    electronic personal health information that is created, received, used, or
    maintained by a covered entity. The Security Rule requires appropriate
    administrative, physical and technical safeguards to ensure the
    confidentiality, integrity, and security of electronic protected health
    information.

    This profile configures Red Hat Enterprise Linux 8 to the HIPAA Security
    Rule identified for securing of electronic protected health information.
    Use of this profile in no way guarantees or makes claims against legal compliance against the HIPAA Security Rule(s).   

selections:
    - grub2_password
    - grub2_uefi_password
    - file_groupowner_grub2_cfg
    - file_permissions_grub2_cfg
    - file_owner_grub2_cfg
    - grub2_disable_interactive_boot
    - no_direct_root_logins
    - no_empty_passwords
    - require_singleuser_auth
    - restrict_serial_port_logins
    - securetty_root_login_console_only
    - service_debug-shell_disabled
    - disable_ctrlaltdel_reboot
    - disable_ctrlaltdel_burstaction
    - dconf_db_up_to_date
    - dconf_gnome_remote_access_credential_prompt
    - dconf_gnome_remote_access_encryption
    - sshd_disable_empty_passwords
    - sshd_disable_root_login
    - libreswan_approved_tunnels
    - no_rsh_trust_files
    - package_rsh-server_removed
    - package_talk_removed
    - package_talk-server_removed
    - package_telnet_removed
    - package_telnet-server_removed
    - package_xinetd_removed
    - service_crond_enabled
    - service_rexec_disabled
    - service_rlogin_disabled
    - service_telnet_disabled
    - service_xinetd_disabled
    - service_zebra_disabled
    - use_kerberos_security_all_exports
    - disable_host_auth
    - sshd_allow_only_protocol2
    - sshd_disable_compression
    - sshd_disable_gssapi_auth
    - sshd_disable_kerb_auth
    - sshd_do_not_permit_user_env
    - sshd_enable_strictmodes
    - sshd_enable_warning_banner
    - var_sshd_set_keepalive=0
    - sshd_set_keepalive_0
    - encrypt_partitions
    - var_system_crypto_policy=fips
    - configure_crypto_policy
    - configure_ssh_crypto_policy
    - var_selinux_policy_name=targeted
    - var_selinux_state=enforcing
    - grub2_enable_selinux
    - sebool_selinuxuser_execheap
    - sebool_selinuxuser_execmod
    - sebool_selinuxuser_execstack
    - selinux_confinement_of_daemons
    - selinux_policytype
    - selinux_state
    - service_kdump_disabled
    - sysctl_fs_suid_dumpable
    - sysctl_kernel_dmesg_restrict
    - sysctl_kernel_exec_shield
    - sysctl_kernel_randomize_va_space
    - rpm_verify_hashes
    - rpm_verify_permissions
    - ensure_redhat_gpgkey_installed
    - ensure_gpgcheck_globally_activated
    - ensure_gpgcheck_never_disabled
    - ensure_gpgcheck_local_packages
    - grub2_audit_argument
    - service_auditd_enabled
    - audit_rules_privileged_commands_sudo
    - audit_rules_privileged_commands_su
    - audit_rules_immutable
    - kernel_module_usb-storage_disabled
    - service_autofs_disabled
    - auditd_audispd_syslog_plugin_activated
    - rsyslog_remote_loghost
    - auditd_data_retention_flush
    - audit_rules_dac_modification_chmod
    - audit_rules_dac_modification_chown
    - audit_rules_dac_modification_fchmodat
    - audit_rules_dac_modification_fchmod
    - audit_rules_dac_modification_fchownat
    - audit_rules_dac_modification_fchown
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
    - audit_rules_file_deletion_events_renameat
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_rmdir
    - audit_rules_file_deletion_events_unlinkat
    - audit_rules_file_deletion_events_unlink
    - audit_rules_kernel_module_loading_delete
    - audit_rules_kernel_module_loading_init
    - audit_rules_login_events_faillock
    - audit_rules_login_events_lastlog
    - audit_rules_login_events_tallylog
    - audit_rules_mac_modification
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
    - audit_rules_privileged_commands_sudoedit
    - audit_rules_privileged_commands_umount
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
    - audit_rules_unsuccessful_file_modification_openat
    - audit_rules_unsuccessful_file_modification_open_by_handle_at
    - audit_rules_unsuccessful_file_modification_open
    - audit_rules_unsuccessful_file_modification_truncate
    - audit_rules_usergroup_modification_group
    - audit_rules_usergroup_modification_gshadow
    - audit_rules_usergroup_modification_opasswd
    - audit_rules_usergroup_modification_passwd
    - audit_rules_usergroup_modification_shadow
