documentation_complete: true

title: 'CIS Ubuntu 22.04 Level 2 Server Benchmark'

description: |-
    This baseline aligns to the Center for Internet Security
    Ubuntu 22.04 LTS Benchmark, v1.0.0, released 07-21-2020.

extends: cis_level1_server

selections:
    ### 1.1.10 Ensure separate partition exists for /var (Automated)
    - partition_for_var

    ### 1.1.11 Ensure separate partition exists for /var/tmp (Automated)
    - partition_for_var_tmp

    ### 1.1.15 Ensure separate partition exists for /var/log (Automated)
    - partition_for_var_log

    ### 1.1.16 Ensure separate partition exists for /var/log/audit (Automated)
    - partition_for_var_log_audit

    ### 1.1.17 Ensure separate partition exists for /home (Automated)
    - partition_for_home

    #### 1.7.1.4 Ensure all AppArmor Profiles are enforcing (Automated)
    # Needs variable; set above appropriately.

    ### 3.4.1 Ensure DCCP is disabled (Automated)
    - kernel_module_dccp_disabled

    ### 3.4.2 Ensure SCTP is disabled (Automated)
    - kernel_module_sctp_disabled

    ### 3.4.3 Ensure RDS is disabled (Automated)
    - kernel_module_rds_disabled

    ### 3.4.4 Ensure TIPC is disabled (Automated)
    - kernel_module_tipc_disabled

    #### 4.1.1.1 Ensure auditd is installed (Automated)
    - package_audit_installed

    #### 4.1.1.2 Ensure auditd service is enabled (Automated)
    - service_auditd_enabled

    #### 4.1.1.3 Ensure auditing for processes that start prior to auditd is enabled (Automated)
    - grub2_audit_argument
    - '!zipl_audit_argument'

    #### 4.1.1.4 Ensure audit_backlog_limit is sufficient (Automated)
    - grub2_audit_backlog_limit_argument
    - '!zipl_audit_backlog_limit_argument'

    #### 4.1.2.1 Ensure audit log storage size is configured (Automated)
    - auditd_data_retention_max_log_file

    #### 4.1.2.2 Ensure audit logs are not automatically deleted (Automated)
    - auditd_data_retention_max_log_file_action

    #### 4.1.2.3 Ensure system is disabled when audit logs are full (Automated)
    - auditd_data_retention_space_left_action
    - auditd_data_retention_action_mail_acct
    - auditd_data_retention_admin_space_left_action

    ### 4.1.3 Ensure events that modify date and time information are collected (Automated)
    - audit_rules_time_clock_settime
    - audit_rules_time_settimeofday
    - audit_rules_time_adjtimex
    - audit_rules_time_stime
    - audit_rules_time_watch_localtime

    ### 4.1.4 Ensure events that modify user/group information are collected (Automated)
    - audit_rules_usergroup_modification_group
    - audit_rules_usergroup_modification_passwd
    - audit_rules_usergroup_modification_gshadow
    - audit_rules_usergroup_modification_shadow
    - audit_rules_usergroup_modification_opasswd

    ### 4.1.5 Ensure events that modify the system's network environment are collected (Automated)
    - audit_rules_networkconfig_modification

    ### 4.1.6 Ensure events that modify the system's Mandatory Access Controls are collected (Automated)
    # Needs rule

    ### 4.1.7 Ensure login and logout events are collected (Automated)
    - audit_rules_login_events_faillog
    - audit_rules_login_events_lastlog
    - audit_rules_login_events_tallylog

    ### 4.1.8 Ensure session initiation information is collected (Automated)
    - audit_rules_session_events

    ### 4.1.9 Ensure discretionary access control permission modification events are collected (Automated)
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

    ### 4.1.10 Ensure unsuccessful unauthorized file access attempts are collected (Automated)
    - audit_rules_unsuccessful_file_modification_creat
    - audit_rules_unsuccessful_file_modification_open
    - audit_rules_unsuccessful_file_modification_openat
    - audit_rules_unsuccessful_file_modification_truncate
    - audit_rules_unsuccessful_file_modification_ftruncate
    # Evaluate the following
    # audit_rules_unsuccessful_file_modification_chmod
    # audit_rules_unsuccessful_file_modification_chown
    # audit_rules_unsuccessful_file_modification_fchmod
    # audit_rules_unsuccessful_file_modification_fchmodat
    # audit_rules_unsuccessful_file_modification_fchown
    # audit_rules_unsuccessful_file_modification_fchownat
    # audit_rules_unsuccessful_file_modification_fremovexattr
    # audit_rules_unsuccessful_file_modification_fsetxattr
    # audit_rules_unsuccessful_file_modification_lchown
    # audit_rules_unsuccessful_file_modification_lremovexattr
    # audit_rules_unsuccessful_file_modification_lsetxattr
    # audit_rules_unsuccessful_file_modification_openat_o_creat
    # audit_rules_unsuccessful_file_modification_openat_o_trunc_write
    # audit_rules_unsuccessful_file_modification_openat_rule_order
    # audit_rules_unsuccessful_file_modification_open_by_handle_at
    # audit_rules_unsuccessful_file_modification_open_by_handle_at_o_creat
    # audit_rules_unsuccessful_file_modification_open_by_handle_at_o_trunc_write
    # audit_rules_unsuccessful_file_modification_open_by_handle_at_rule_order
    # audit_rules_unsuccessful_file_modification_open_o_creat
    # audit_rules_unsuccessful_file_modification_open_o_trunc_write
    # audit_rules_unsuccessful_file_modification_open_rule_order
    # audit_rules_unsuccessful_file_modification_removexattr
    # audit_rules_unsuccessful_file_modification_rename
    # audit_rules_unsuccessful_file_modification_renameat
    # audit_rules_unsuccessful_file_modification_renameat2
    # audit_rules_unsuccessful_file_modification_setxattr
    # audit_rules_unsuccessful_file_modification_unlink
    # audit_rules_unsuccessful_file_modification_unlinkat

    ### 4.1.11 Ensure use of privileged commands is collected (Automated)
    - audit_rules_privileged_commands_at
    - audit_rules_privileged_commands_chage
    - audit_rules_privileged_commands_chfn
    - audit_rules_privileged_commands_chsh
    - audit_rules_privileged_commands_crontab
    - audit_rules_privileged_commands_gpasswd
    - audit_rules_privileged_commands_mount
    - audit_rules_privileged_commands_newgidmap
    - audit_rules_privileged_commands_newgrp
    - audit_rules_privileged_commands_newuidmap
    - audit_rules_privileged_commands_postdrop
    - audit_rules_privileged_commands_postqueue
    - audit_rules_privileged_commands_ssh_agent
    - audit_rules_privileged_commands_ssh_keysign
    - audit_rules_privileged_commands_su
    - audit_rules_privileged_commands_sudo
    - audit_rules_privileged_commands_sudoedit
    - audit_rules_privileged_commands_umount
    - audit_rules_privileged_commands_unix_chkpwd

    ### 4.1.12 Ensure successful file system mounts are collected (Automated)
    # Needs rule

    ### 4.1.13 Ensure file deletion events by users are collected (Automated)
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_renameat
    - audit_rules_file_deletion_events_unlink
    - audit_rules_file_deletion_events_unlinkat

    ### 4.1.14 Ensure changes to system administration scope (sudoers) is collected (Automated)
    - audit_rules_sysadmin_actions

    ### 4.1.15 Ensure system administrator command executions (sudo) are collected (Automated)
    - audit_rules_suid_privilege_function

    ### 4.1.16 Ensure kernel module loading and unloading is collected (Automated)
    - audit_rules_kernel_module_loading_init
    - audit_rules_kernel_module_loading_delete
    - audit_rules_privileged_commands_modprobe
    - audit_rules_privileged_commands_insmod
    - audit_rules_privileged_commands_rmmod

    ### 4.1.17 Ensure the audit configuration is immutable (Automated)
    - audit_rules_immutable

    ### 5.2.5 Ensure SSH X11 forwarding is disabled (Automated)
    - sshd_disable_x11_forwarding

    ### 5.2.20 Ensure SSH AllowTcpForwarding is disabled (Automated)
    - sshd_disable_tcp_forwarding
