documentation_complete: true

metadata:
    version: 2.2.0
    SMEs:
        - vojtapolasek
        - yuumasato

reference: https://www.cisecurity.org/cis-benchmarks/#red_hat_linux


title: 'CIS Red Hat Enterprise Linux 7 Benchmark'

description: |-
    This profile defines a baseline that aligns to the Center for Internet Security®
    Red Hat Enterprise Linux 7 Benchmark™, v2.2.0, released 12-27-2017.

    This profile includes Center for Internet Security®
    Red Hat Enterprise Linux 7 CIS Benchmarks™ content.

selections:
    # Necessary for dconf rules
    - dconf_db_up_to_date

    # 1 Initial Setup
    ## 1.1 Filesystem Configuration
    ### 1.1.1 Disable unused filesystems
    #### 1.1.1.1 Ensure mounting of cramfs filesystems is disabled (Scored)
    - kernel_module_cramfs_disabled

    #### 1.1.1.2 Ensure mounting of freevxfs filesystems is disabled (Scored)
    - kernel_module_freevxfs_disabled

    #### 1.1.1.3 Ensure mounting of jffs2 filesystems is disabled (Scored)
    - kernel_module_jffs2_disabled

    #### 1.1.1.4 Ensure mounting of hfs filesystems is disabled (Scored)
    - kernel_module_hfs_disabled

    #### 1.1.1.5 Ensure mounting of hfsplus filesystems is disabled (Scored)
    - kernel_module_hfsplus_disabled

    #### 1.1.1.6 Ensure mounting of squashfs filesystems is disabled (Scored)
    - kernel_module_squashfs_disabled

    #### 1.1.1.7 Ensure mounting of udf filesystems is disabled (Scored)
    - kernel_module_udf_disabled

    #### 1.1.1.8 Ensure mounting of FAT filesystems is disabled (Scored)
    - kernel_module_vfat_disabled

    ### 1.1.2 Ensure separate partition exists for /tmp (Scored)
    - partition_for_tmp

    ### 1.1.3 Ensure nodev option set on /tmp partition (Scored)
    - mount_option_tmp_nodev

    ### 1.1.4 Ensure nosuid option set on /tmp partition (Scored)
    - mount_option_tmp_nosuid

    ### 1.1.5 Ensure noexec option set on /tmp partition (Scored)
    - mount_option_tmp_noexec

    ### 1.1.6 Ensure separate partition exists for /var (Scored)
    - partition_for_var

    ### 1.1.7 Ensure separate partition exists for /var/tmp (Scored)
    - partition_for_var_tmp

    ### 1.1.8 Ensure nodev option set on /var/tmp partition (Scored)
    - mount_option_var_tmp_nodev

    ### 1.1.9 Ensure nosuid option set on /var/tmp partition (Scored)
    - mount_option_var_tmp_nosuid

    ### 1.1.10 Ensure noexec option set on /var/tmp partition (Scored)
    - mount_option_var_tmp_noexec

    ### 1.1.11 Ensure separate partition exists for /var/log (Scored)
    - partition_for_var_log

    ### 1.1.12 Ensure separate partition exists for /var/log/audit (Scored)
    - partition_for_var_log_audit

    ### 1.1.13 Ensure separate partition exists for /home (Scored)
    - partition_for_home

    ### 1.1.14 Ensure nodev option set on /home partition (Scored)
    - mount_option_home_nodev

    ### 1.1.15 Ensure nodev option set on /dev/shm partition (Scored)
    - mount_option_dev_shm_nodev

    ### 1.1.16 Ensure nosuid option set on /dev/shm partition (Scored)
    - mount_option_dev_shm_nosuid

    ### 1.1.17 Ensure noexec option set on /dev/shm partition (Scored)
    - mount_option_dev_shm_noexec

    ### 1.1.18 Ensure nodev option set on removable media partitions (Not Scored)
    - mount_option_nodev_removable_partitions

    ### 1.1.19 Ensure nosuid option set on removable media partitions (Not Scored)
    - mount_option_nosuid_removable_partitions

    ### 1.1.20 Ensure noexec option set on removable media partitions (Not Scored)
    - mount_option_noexec_removable_partitions

    ### 1.1.21 Ensure sticky bit is set on all world-writable directories (Scored)
    - dir_perms_world_writable_sticky_bits

    ### 1.1.22 Disable Automounting (Scored)
    - service_autofs_disabled

    ## 1.2 Configure Software Updates
    ### 1.2.1 Ensure package manager repositories are configured (Not Scored)
    ### 1.2.2 Ensure gpgcheck is globally activated (Scored)
    - ensure_gpgcheck_globally_activated

    ### 1.2.3 Ensure GPG keys are configured (Not Scored)
    - ensure_redhat_gpgkey_installed

    ### 1.2.4 Ensure Red Hat Subscription Manager connection is configured (Not Scored)

    ### 1.2.5 Disable the rhnsd Daemon (Not Scored)
    - service_rhnsd_disabled

    ## 1.3 Filesystem Integrity Checking
    ### 1.3.1 Ensure AIDE is installed (Scored)
    - package_aide_installed

    ### 1.3.2 Ensure filesystem integrity is regularly checked (Scored)
    - aide_periodic_cron_checking

    ## 1.4 Secure Boot Settings
    ### 1.4.1 Ensure permissions on bootloader config are configured (Scored)
    - file_owner_grub2_cfg
    - file_groupowner_grub2_cfg
    - file_permissions_grub2_cfg

    ### 1.4.2 Ensure bootloader password is set (Scored)
    - grub2_password

    ### 1.4.3 Ensure authentication required for single user mode (Scored)
    - require_singleuser_auth

    ## 1.5 Additional Process Hardening
    ### 1.5.1 Ensure core dumps are restricted (Scored)
    - disable_users_coredumps
    - sysctl_fs_suid_dumpable

    ### 1.5.2 Ensure XD/NX support is enabled (Not Scored)
    - sysctl_kernel_exec_shield
    - bios_enable_execution_restrictions
    - install_PAE_kernel_on_x86-32

    ### 1.5.3 Ensure address space layout randomization (ASLR) is enabled (Scored)
    - sysctl_kernel_randomize_va_space

    ### 1.5.4 Ensure prelink is disabled (Scored)
    - disable_prelink

    ## 1.6 Mandatory Access Control
    ### 1.6.1 Configure SELinux
    #### 1.6.1.1 Ensure SELinux is not disabled in bootloader configuration (Scored)
    - grub2_enable_selinux

    #### 1.6.1.2 Ensure the SELinux state is enforcing (Scored)
    - var_selinux_state=enforcing
    - selinux_state

    #### 1.6.1.3 Ensure SELinux policy is configured (Scored)
    - var_selinux_policy_name=targeted
    - selinux_policytype

    #### 1.6.1.4 Ensure SETroubleshoot is not installed (Scored)
    - package_setroubleshoot_removed

    #### 1.6.1.5 Ensure the MCS Translation Service (mcstrans) is not installed (Scored)
    - package_mcstrans_removed

    #### 1.6.1.6 Ensure no unconfined daemons exist (Scored)
    - selinux_confinement_of_daemons

    ### 1.6.2 Ensure SELinux is installed (Scored)
    - package_libselinux_installed

    ## 1.7 Warning Banners
    #### 1.7.1.1 Ensure message of the day is configured properly (Scored)
    - banner_etc_motd

    #### 1.7.1.2 Ensure local login warning banner is configured properly (Not Scored)
    - banner_etc_issue
    # TODO define banner text
    #- login_banner_text=

    #### 1.7.1.3 Ensure remote login warning banner is configured properly (Not Scored)

    #### 1.7.1.4 Ensure permissions on /etc/motd are configured (Not Scored)
    #### 1.7.1.5 Ensure permissions on /etc/issue are configured (Scored)
    #### 1.7.1.6 Ensure permissions on /etc/issue.net are configured (Not Scored)

    ### 1.7.2 Ensure GDM login banner is configured (Scored)
    - dconf_gnome_login_banner_text
    - dconf_gnome_banner_enabled

    ## 1.8 Ensure updates, patches, and additional security software are installed (Scored)
    - security_patches_up_to_date

    # 2 Services

    ## 2.1 inetd Services

    ### 2.1.1 Ensure chargen services are not enabled (Scored)
    ### 2.1.2 Ensure daytime services are not enabled (Scored)
    ### 2.1.3 Ensure discard services are not enabled (Scored)
    ### 2.1.4 Ensure echo services are not enabled (Scored)
    ### 2.1.5 Ensure time services are not enabled (Scored)
    ### 2.1.6 Ensure tftp server is not enabled (Scored)
    - service_tftp_disabled

    ### 2.1.7 Ensure xinetd is not enabled (Scored)
    - service_xinetd_disabled

    ## 2.2 Special Purpose Services
    #### 2.2.1.1 Ensure time synchronization is in use (Not Scored)
    - package_chrony_installed

    #### 2.2.1.2 Ensure ntp is configured (Scored)
    # This requirement is not applicable
    # This profile opts to use chrony rather than ntp

    #### 2.2.1.3 Ensure chrony is configured (Scored)
    - service_chronyd_enabled
    - chronyd_specify_remote_server
    - chronyd_run_as_chrony_user

    ### 2.2.2 Ensure X Window System is not installed (Scored)
    - package_xorg-x11-server-common_removed
    - xwindows_runlevel_target

    ### 2.2.3 Ensure Avahi Server is not enabled (Scored)
    - service_avahi-daemon_disabled

    ### 2.2.4 Ensure CUPS is not enabled (Scored)
    - service_cups_disabled

    ### 2.2.5 Ensure DHCP Server is not enabled (Scored)
    - service_dhcpd_disabled

    ### 2.2.6 Ensure LDAP server is not enabled (Scored)
    - package_openldap-servers_removed

    ### 2.2.7 Ensure NFS and RPC are not enabled (Scored)
    - service_nfs_disabled
    - service_rpcbind_disabled

    ### 2.2.8 Ensure DNS Server is not enabled (Scored)
    - service_named_disabled

    ### 2.2.9 Ensure FTP Server is not enabled (Scored)
    - service_vsftpd_disabled

    ### 2.2.10 Ensure HTTP server is not enabled (Scored)
    - service_httpd_disabled

    ### 2.2.11 Ensure IMAP and POP3 server is not enabled (Scored)
    - service_dovecot_disabled

    ### 2.2.12 Ensure Samba is not enabled (Scored)
    - service_smb_disabled

    ### 2.2.13 Ensure HTTP Proxy Server is not enabled (Scored)
    - service_squid_disabled

    ### 2.2.14 Ensure SNMP Server is not enabled (Scored)
    - service_snmpd_disabled

    ### 2.2.15 Ensure mail transfer agent is configured for local-only mode (Scored)
    - postfix_network_listening_disabled

    ### 2.2.16 Ensure NIS Server is not enabled (Scored)
    - package_ypserv_removed

    ### 2.2.17 Ensure rsh server is not enabled (Scored)
    - service_rsh_disabled
    - service_rlogin_disabled
    - service_rexec_disabled

    ### 2.2.18 Ensure talk server is not enabled (Scored)
    - package_talk-server_removed

    ### 2.2.19 Ensure telnet server is not enabled (Scored)
    - service_telnet_disabled

    ### 2.2.20 Ensure tftp server is not enabled (Scored)
    - service_tftp_disabled

    ### 2.2.21 Ensure rsync service is not enabled (Scored)

    ## 2.3 Service Clients
    ### 2.3.1 Ensure NIS Client is not installed (Scored)
    - package_ypbind_removed

    ### 2.3.2 Ensure rsh client is not installed (Scored)
    - package_rsh_removed

    ### 2.3.3 Ensure talk client is not installed (Scored)
    - package_talk_removed

    ### 2.3.4 Ensure telnet client is not installed (Scored)
    - package_telnet_removed

    ### 2.3.5 Ensure LDAP client is not installed (Scored)
    - package_openldap-clients_removed

    # 3 Network Configuration
    ## 3.1 Network Parameters (Host Only)
    ### 3.1.1 Ensure IP forwarding is disabled (Scored)
    - sysctl_net_ipv4_ip_forward

    ### 3.1.2 Ensure packet redirect sending is disabled (Scored)
    - sysctl_net_ipv4_conf_all_send_redirects
    - sysctl_net_ipv4_conf_default_send_redirects

    ## 3.2 Network Parameters (Host and Router)
    ### 3.2.1 Ensure source routed packets are not accepted (Scored)
    - sysctl_net_ipv4_conf_all_accept_source_route
    - sysctl_net_ipv4_conf_default_accept_source_route

    ### 3.2.2 Ensure ICMP redirects are not accepted (Scored)
    - sysctl_net_ipv4_conf_all_accept_redirects
    - sysctl_net_ipv4_conf_default_accept_redirects

    ### 3.2.3 Ensure secure ICMP redirects are not accepted (Scored)
    - sysctl_net_ipv4_conf_all_secure_redirects
    - sysctl_net_ipv4_conf_default_secure_redirects

    ### 3.2.4 Ensure suspicious packets are logged (Scored)
    - sysctl_net_ipv4_conf_all_log_martians
    - sysctl_net_ipv4_conf_default_log_martians

    ### 3.2.5 Ensure broadcast ICMP requests are ignored (Scored)
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts

    ### 3.2.6 Ensure bogus ICMP responses are ignored (Scored)
    - sysctl_net_ipv4_icmp_ignore_bogus_error_responses

    ### 3.2.7 Ensure Reverse Path Filtering is enabled (Scored)
    - sysctl_net_ipv4_conf_all_rp_filter
    - sysctl_net_ipv4_conf_default_rp_filter

    ### 3.2.8 Ensure TCP SYN Cookies is enabled (Scored)
    - sysctl_net_ipv4_tcp_syncookies

    ## 3.3 IPv6
    ### 3.3.1 Ensure IPv6 router advertisements are not accepted (Not Scored)
    - sysctl_net_ipv6_conf_all_accept_ra
    - sysctl_net_ipv6_conf_default_accept_ra

    ### 3.3.2 Ensure IPv6 redirects are not accepted (Not Scored)
    - sysctl_net_ipv6_conf_all_accept_redirects
    - sysctl_net_ipv6_conf_default_accept_redirects

    ### 3.3.3 Ensure IPv6 is disabled (Not Scored)
    - kernel_module_ipv6_option_disabled

    ## 3.4 TCP Wrappers
    ### 3.4.1 Ensure TCP Wrappers is installed (Scored)
    - package_tcp_wrappers_installed

    ### 3.4.2 Ensure /etc/hosts.allow is configured (Scored)
    ### 3.4.3 Ensure /etc/hosts.deny is configured (Scored)
    - configure_etc_hosts_deny

    ### 3.4.4 Ensure permissions on /etc/hosts.allow are configured (Scored)
    - file_owner_etc_hosts_allow
    - file_groupowner_etc_hosts_allow
    - file_permissions_etc_hosts_allow

    ### 3.4.5 Ensure permissions on /etc/hosts.deny are configured (Scored)
    - file_owner_etc_hosts_deny
    - file_groupowner_etc_hosts_deny
    - file_permissions_etc_hosts_deny

    ## 3.5 Uncommon Network Protocols
    ### 3.5.1 Ensure DCCP is disabled (Not Scored)
    - kernel_module_dccp_disabled

    ### 3.5.2 Ensure SCTP is disabled (Not Scored)
    - kernel_module_sctp_disabled

    ### 3.5.3 Ensure RDS is disabled (Not Scored)
    - kernel_module_rds_disabled

    ### 3.5.4 Ensure TIPC is disabled (Not Scored)
    - kernel_module_tipc_disabled

    ## 3.6 Firewall Configuration
    ### 3.6.1 Ensure iptables is installed (Scored)
    - package_iptables_installed

    ### 3.6.2 Ensure default deny firewall policy (Scored)
    ### 3.6.3 Ensure loopback traffic is configured (Scored)
    ### 3.6.4 Ensure outbound and established connections are configured (Not Scored)
    ### 3.6.5 Ensure firewall rules exist for all open ports (Scored)
    ## 3.7 Ensure wireless interfaces are disabled (Not Scored)
    - wireless_disable_interfaces

    # 4 Logging and Auditing
    ## 4.1 Configure System Accounting (auditd)
    #### 4.1.1.1 Ensure audit log storage size is configured (Not Scored)
    - auditd_data_retention_max_log_file

    #### 4.1.1.2 Ensure system is disabled when audit logs are full (Scored)
    - var_auditd_space_left_action=email
    - auditd_data_retention_space_left_action
    - var_auditd_action_mail_acct=root
    - auditd_data_retention_action_mail_acct
    - var_auditd_admin_space_left_action=halt
    - auditd_data_retention_admin_space_left_action

    #### 4.1.1.3 Ensure audit logs are not automatically deleted (Scored)
    - var_auditd_max_log_file_action=keep_logs
    - auditd_data_retention_max_log_file_action

    ### 4.1.2 Ensure auditd service is enabled (Scored)
    - service_auditd_enabled

    ### 4.1.3 Ensure auditing for processes that start prior to auditd is enabled (Scored)
    - grub2_audit_argument

    ### 4.1.4 Ensure events that modify date and time information are collected (Scored)
    - audit_rules_time_adjtimex
    - audit_rules_time_settimeofday
    - audit_rules_time_stime
    - audit_rules_time_clock_settime
    - audit_rules_time_watch_localtime

    ### 4.1.5 Ensure events that modify user/group information are collected (Scored)
    - audit_rules_usergroup_modification_passwd
    - audit_rules_usergroup_modification_group
    - audit_rules_usergroup_modification_gshadow
    - audit_rules_usergroup_modification_shadow
    - audit_rules_usergroup_modification_opasswd

    ### 4.1.6 Ensure events that modify the system's network environment are collected (Scored)
    - audit_rules_networkconfig_modification # needs update to cover network-sripts and system-locale

    ### 4.1.7 Ensure events that modify the system's Mandatory Access Controls are collected (Scored)
    - audit_rules_mac_modification
    # NEED RULE - https://github.com/ComplianceAsCode/content/issues/5264

    ### 4.1.8 Ensure login and logout events are collected (Scored)
    - audit_rules_login_events_lastlog
    - audit_rules_login_events_faillock

    ### 4.1.9 Ensure session initiation information is collected (Scored)
    - audit_rules_session_events

    ### 4.1.10 Ensure discretionary access control permission modification events are collected (Scored)
    - audit_rules_dac_modification_chmod
    - audit_rules_dac_modification_fchmod
    - audit_rules_dac_modification_fchmodat
    - audit_rules_dac_modification_chown
    - audit_rules_dac_modification_fchown
    - audit_rules_dac_modification_fchownat
    - audit_rules_dac_modification_lchown
    - audit_rules_dac_modification_setxattr
    - audit_rules_dac_modification_lsetxattr
    - audit_rules_dac_modification_fsetxattr
    - audit_rules_dac_modification_removexattr
    - audit_rules_dac_modification_lremovexattr
    - audit_rules_dac_modification_fremovexattr

    ### 4.1.11 Ensure unsuccessful unauthorized file access attempts are collected (Scored)
    - audit_rules_unsuccessful_file_modification_creat
    - audit_rules_unsuccessful_file_modification_open
    - audit_rules_unsuccessful_file_modification_openat
    - audit_rules_unsuccessful_file_modification_truncate
    - audit_rules_unsuccessful_file_modification_ftruncate
    # Opinionated selection
    - audit_rules_unsuccessful_file_modification_open_by_handle_at

    ### 4.1.12 Ensure use of privileged commands is collected (Scored)
    - audit_rules_privileged_commands

    ### 4.1.13 Ensure successful file system mounts are collected (Scored)
    - audit_rules_media_export

    ### 4.1.14 Ensure file deletion events by users are collected (Scored)
    - audit_rules_file_deletion_events_unlink
    - audit_rules_file_deletion_events_unlinkat
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_renameat
    # Opinionated selection
    - audit_rules_file_deletion_events_rmdir

    ### 4.1.15 Ensure changes to system administration scope (sudoers) is collected (Scored)
    - audit_rules_sysadmin_actions

    ### 4.1.16 Ensure system administrator actions (sudolog) are collected (Scored)

    ### 4.1.17 Ensure kernel module loading and unloading is collected (Scored)
    - audit_rules_kernel_module_loading

    ### 4.1.18 Ensure the audit configuration is immutable (Scored)
    - audit_rules_immutable

    ## 4.2 Configure Logging
    #### 4.2.1.1 Ensure rsyslog Service is enabled (Scored)
    - service_rsyslog_enabled

    #### 4.2.1.2 Ensure logging is configured (Not Scored)

    #### 4.2.1.3 Ensure rsyslog default file permissions configured (Scored)
    - rsyslog_files_permissions

    #### 4.2.1.4 Ensure rsyslog is configured to send logs to a remote log host (Scored)
    - rsyslog_remote_loghost

    #### 4.2.1.5 Ensure remote rsyslog messages are only accepted on designated log hosts. (Not Scored)
    - rsyslog_nolisten
    - rsyslog_accept_remote_messages_tcp
    - rsyslog_accept_remote_messages_udp

    #### 4.2.2.1 Ensure syslog-ng service is enabled (Scored)
    #### 4.2.2.2 Ensure logging is configured (Not Scored)
    #### 4.2.2.3 Ensure syslog-ng default file permissions configured (Scored)
    #### 4.2.2.4 Ensure syslog-ng is configured to send logs to a remote log host (Not Scored)
    #### 4.2.2.5 Ensure remote syslog-ng messages are only accepted on designated log hosts (Not Scored)
    # Whole section 4.2.2.X is not applicable
    # This profile opts to use rsyslog rather than syslog-ng

    ### 4.2.3 Ensure rsyslog or syslog-ng is installed (Scored)
    - package_rsyslog_installed

    ### 4.2.4 Ensure permissions on all logfiles are configured (Scored)

    ## 4.3 Ensure logrotate is configured (Not Scored)
    - ensure_logrotate_activated

    # 5 Access, Authentication and Authorization
    ## 5.1 Configure cron
    ### 5.1.1 Ensure cron daemon is enabled (Scored)
    - service_crond_enabled

    ### 5.1.2 Ensure permissions on /etc/crontab are configured (Scored)
    - file_groupowner_crontab
    - file_owner_crontab
    - file_permissions_crontab

    ### 5.1.3 Ensure permissions on /etc/cron.hourly are configured (Scored)
    - file_groupowner_cron_hourly
    - file_owner_cron_hourly
    - file_permissions_cron_hourly

    ### 5.1.4 Ensure permissions on /etc/cron.daily are configured (Scored)
    - file_groupowner_cron_daily
    - file_owner_cron_daily
    - file_permissions_cron_daily

    ### 5.1.5 Ensure permissions on /etc/cron.weekly are configured (Scored)
    - file_groupowner_cron_weekly
    - file_owner_cron_weekly
    - file_permissions_cron_weekly

    ### 5.1.6 Ensure permissions on /etc/cron.monthly are configured (Scored)
    - file_groupowner_cron_monthly
    - file_owner_cron_monthly
    - file_permissions_cron_monthly

    ### 5.1.7 Ensure permissions on /etc/cron.d are configured (Scored)
    - file_groupowner_cron_d
    - file_owner_cron_d
    - file_permissions_cron_d

    ### 5.1.8 Ensure at/cron is restricted to authorized users (Scored)

    ## 5.2 SSH Server Configuration
    ### 5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured (Scored)
    - file_groupowner_sshd_config
    - file_owner_sshd_config
    - file_permissions_sshd_config

    ### 5.2.2 Ensure SSH Protocol is set to 2 (Scored)
    - sshd_allow_only_protocol2

    ### 5.2.3 Ensure SSH LogLevel is set to INFO (Scored)
    - sshd_set_loglevel_info

    ### 5.2.4 Ensure SSH X11 forwarding is disabled (Scored)
    - sshd_disable_x11_forwarding
    
    ### 5.2.5 Ensure SSH MaxAuthTries is set to 4 or less (Scored)
    - sshd_max_auth_tries_value=4
    - sshd_set_max_auth_tries

    ### 5.2.6 Ensure SSH IgnoreRhosts is enabled (Scored)
    - sshd_disable_rhosts

    ### 5.2.7 Ensure SSH HostbasedAuthentication is disabled (Scored)
    - disable_host_auth

    ### 5.2.8 Ensure SSH root login is disabled (Scored)
    - sshd_disable_root_login

    ### 5.2.9 Ensure SSH PermitEmptyPasswords is disabled (Scored)
    - sshd_disable_empty_passwords

    ### 5.2.10 Ensure SSH PermitUserEnvironment is disabled (Scored)
    - sshd_do_not_permit_user_env

    ### 5.2.11 Ensure only approved MAC algorithms are used (Scored)
    - sshd_use_approved_macs # TODO: approved macs don't match

    ### 5.2.12 Ensure SSH Idle Timeout Interval is configured (Scored)
    - sshd_set_idle_timeout
    - sshd_set_keepalive

    ### 5.2.13 Ensure SSH LoginGraceTime is set to one minute or less (Scored)
    ### 5.2.14 Ensure SSH access is limited (Scored)
    - sshd_limit_user_access
    # TODO: cover AllowUsers, AllowGroups, DenyGroups

    ### 5.2.15 Ensure SSH warning banner is configured (Scored)
    - sshd_enable_warning_banner

    ## 5.3 Configure PAM
    ### 5.3.1 Ensure password creation requirements are configured (Scored)
    - accounts_password_pam_retry
    # TODO: looks like try_first_pass is not covered
    - var_password_pam_minlen=14
    - accounts_password_pam_minlen
    - var_password_pam_dcredit=1
    - accounts_password_pam_dcredit
    - var_password_pam_ucredit=1
    - accounts_password_pam_ucredit
    - var_password_pam_ocredit=1
    - accounts_password_pam_ocredit
    - var_password_pam_lcredit=1
    - accounts_password_pam_lcredit

    ### 5.3.2 Ensure lockout for failed password attempts is configured (Scored)
    - var_accounts_passwords_pam_faillock_unlock_time=900
    - var_accounts_passwords_pam_faillock_deny=5
    - accounts_passwords_pam_faillock_unlock_time
    - accounts_passwords_pam_faillock_deny

    ### 5.3.3 Ensure password reuse is limited (Scored)
    - var_password_pam_unix_remember=5
    - accounts_password_pam_unix_remember

    ### 5.3.4 Ensure password hashing algorithm is SHA-512 (Scored)
    - set_password_hashing_algorithm_systemauth
    # TODO: password-auth is not covered

    ## 5.4 User Accounts and Environment
    ### 5.4.1 Set Shadow Password Suite Parameters
    #### 5.4.1.1 Ensure password expiration is 365 days or less (Scored)
    - var_accounts_maximum_age_login_defs=90
    - accounts_maximum_age_login_defs

    #### 5.4.1.2 Ensure minimum days between password changes is 7 or more (Scored)
    - var_accounts_minimum_age_login_defs=7
    - accounts_minimum_age_login_defs

    #### 5.4.1.3 Ensure password expiration warning days is 7 or more (Scored)
    - var_accounts_password_warn_age_login_defs=7
    - accounts_password_warn_age_login_defs

    #### 5.4.1.4 Ensure inactive password lock is 30 days or less (Scored)
    - var_account_disable_post_pw_expiration=30
    - account_disable_post_pw_expiration

    #### 5.4.1.5 Ensure all users last password change date is in the past (Scored)
    ### 5.4.2 Ensure system accounts are non-login (Scored)
    - no_shelllogin_for_systemaccounts

    ### 5.4.3 Ensure default group for the root account is GID 0 (Scored)
    ### 5.4.4 Ensure default user umask is 027 or more restrictive (Scored)
    - accounts_umask_etc_bashrc
    - accounts_umask_etc_profile

    ### 5.4.5 Ensure default user shell timeout is 900 seconds or less (Scored)
    - accounts_tmout

    ## 5.5 Ensure root login is restricted to system console (Not Scored)
    - no_direct_root_logins

    ## 5.6 Ensure access to the su command is restricted (Scored)

    # 6 System Maintenance
    ## 6.1 System File Permissions
    ### 6.1.1 Audit system file permissions (Not Scored)
    - rpm_verify_permissions
    - rpm_verify_ownership

    ### 6.1.2 Ensure permissions on /etc/passwd are configured (Scored)
    - file_owner_etc_passwd
    - file_groupowner_etc_passwd
    - file_permissions_etc_passwd

    ### 6.1.3 Ensure permissions on /etc/shadow are configured (Scored)
    - file_owner_etc_shadow
    - file_groupowner_etc_shadow
    - file_permissions_etc_shadow

    ### 6.1.4 Ensure permissions on /etc/group are configured (Scored)
    - file_owner_etc_group
    - file_groupowner_etc_group
    - file_permissions_etc_group

    ### 6.1.5 Ensure permissions on /etc/gshadow are configured (Scored)
    - file_owner_etc_gshadow
    - file_groupowner_etc_gshadow
    - file_permissions_etc_gshadow

    ### 6.1.6 Ensure permissions on /etc/passwd- are configured (Scored)
    - file_owner_backup_etc_passwd
    - file_groupowner_backup_etc_passwd
    - file_permissions_backup_etc_passwd

    ### 6.1.7 Ensure permissions on /etc/shadow- are configured (Scored)
    - file_owner_backup_etc_shadow
    - file_groupowner_backup_etc_shadow
    - file_permissions_backup_etc_shadow

    ### 6.1.8 Ensure permissions on /etc/group- are configured (Scored)
    - file_owner_backup_etc_group
    - file_groupowner_backup_etc_group
    - file_permissions_backup_etc_group

    ### 6.1.9 Ensure permissions on /etc/gshadow- are configured (Scored)
    - file_owner_backup_etc_gshadow
    - file_groupowner_backup_etc_gshadow
    - file_permissions_backup_etc_gshadow

    ### 6.1.10 Ensure no world writable files exist (Scored)
    - file_permissions_unauthorized_world_writable

    ### 6.1.11 Ensure no unowned files or directories exist (Scored)
    - no_files_unowned_by_user

    ### 6.1.12 Ensure no ungrouped files or directories exist (Scored)
    - file_permissions_ungroupowned

    ### 6.1.13 Audit SUID executables (Not Scored)
    - file_permissions_unauthorized_suid

    ### 6.1.14 Audit SGID executables (Not Scored)
    - file_permissions_unauthorized_sgid

    ## 6.2 User and Group Settings
    ### 6.2.1 Ensure password fields are not empty (Scored)
    ### 6.2.2 Ensure no legacy "+" entries exist in /etc/passwd (Scored)
    - no_legacy_plus_entries_etc_passwd

    ### 6.2.3 Ensure no legacy "+" entries exist in /etc/shadow (Scored)
    - no_legacy_plus_entries_etc_shadow

    ### 6.2.4 Ensure no legacy "+" entries exist in /etc/group (Scored)
    - no_legacy_plus_entries_etc_group

    ### 6.2.5 Ensure root is the only UID 0 account (Scored)
    - accounts_no_uid_except_zero

    ### 6.2.6 Ensure root PATH Integrity (Scored)
    ### 6.2.7 Ensure all users' home directories exist (Scored)
    ### 6.2.8 Ensure users' home directories permissions are 750 or more restrictive (Scored)
    ### 6.2.9 Ensure users own their home directories (Scored)
    ### 6.2.10 Ensure users' dot files are not group or world writable (Scored)
    ### 6.2.11 Ensure no users have .forward files (Scored)
    ### 6.2.12 Ensure no users have .netrc files (Scored)
    ### 6.2.13 Ensure users' .netrc Files are not group or world accessible (Scored)
    ### 6.2.14 Ensure no users have .rhosts files (Scored)
    - no_rsh_trust_files

    ### 6.2.15 Ensure all groups in /etc/passwd exist in /etc/group (Scored)
    ### 6.2.16 Ensure no duplicate UIDs exist (Scored)
    ### 6.2.17 Ensure no duplicate GIDs exist (Scored)
    ### 6.2.18 Ensure no duplicate user names exist (Scored)
    ### 6.2.19 Ensure no duplicate group names exist (Scored)
