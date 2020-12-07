documentation_complete: true

metadata:
    version: 1.1.0
    SMEs:
        - truzzon

reference: https://www.cisecurity.org/cis-benchmarks/#suse_linux


title: 'CIS SUSE Linux Enterprise 15 Benchmark'

description: |-
    This profile defines a baseline that aligns to the Center for Internet Security®
    SUSE Linux Enterprise 15 Benchmark™, v1.0.0, released 07-30-2020.

    This profile includes Center for Internet Security®
    SUSE Linux Enterprise 15 CIS Benchmarks™ content.

selections:

    # Necessary for dconf rules
    - dconf_db_up_to_date

    ## 1.1 Filesystem Configuration
    ### 1.1.1 Disable unused filesystems
    #### 1.1.1.1 Ensure mounting of squashfs filesystems is disabled (Automated)
    - kernel_module_squashfs_disabled

    #### 1.1.1.2 Ensure mounting of udf filesystems is disabled (Automated)
    - kernel_module_udf_disabled

    #### 1.1.1.3 Ensure mounting of vFAT flesystems is limited (Manual)
    - kernel_module_vfat_disabled

    ### 1.1.2 Ensure /tmp is configured (Automated)
    - partition_for_tmp    

    ### 1.1.3 Ensure noexec option set on /tmp partition (Automated)
    - mount_option_tmp_noexec

    ### 1.1.4 Ensure nodev option set on /tmp partition (Automated)
    - mount_option_tmp_nodev

    ### 1.1.5 Ensure nosuid option set on /tmp partition (Automated)
    - mount_option_tmp_nosuid

    ### 1.1.6 Ensure /dev/shm is configured (Automated)

    ### 1.1.7 Ensure noexec option set on /dev/shm (Automated)
    - mount_option_dev_shm_noexec

    ### 1.1.8 Ensure nodev option set on /dev/shm (Automated)
    - mount_option_dev_shm_nodev

    ### 1.1.9 Ensure nosuid option set on /dev/shm (Automated)
    - mount_option_dev_shm_nosuid

    ### 1.1.10 Ensure separate partition exists for /var (Automated)
    - partition_for_var

    ### 1.1.11 Ensure separate partition exists for /var/tmp (Automated)
    - partition_for_var_tmp

    ### 1.1.12 Ensure nodev option set on /var/tmp partition (Automated)
    - mount_option_var_tmp_nodev

    ### 1.1.13 Ensure nosuid option set on /var/tmp partition (Automated)
    - mount_option_var_tmp_nosuid

    ### 1.1.14 Ensure noexec option set on /var/tmp partition (Automated)
    - mount_option_var_tmp_noexec

    ### 1.1.15 Ensure separate partition exists for /var/log (Automated)
    - partition_for_var_log

    ### 1.1.16 Ensure separate partition exists for /var/log/audit (Automated)
    - partition_for_var_log_audit

    ### 1.1.17 Ensure separate partition exists for /home (Automated)
    - partition_for_home

    ### 1.1.18 Ensure nodev option set on /home partition (Automated)
    - mount_option_home_nodev

    ### 1.1.19 Ensure nodev option set on removable media partitions (Manual)
    - mount_option_nodev_removable_partitions

    ### 1.1.20 Ensure nosuid option set on removable media partitions (Manual)
    - mount_option_nosuid_removable_partitions

    ### 1.1.21 Ensure noexec option set on removable media partitions (Manual)
    - mount_option_noexec_removable_partitions

    ### 1.1.22 Ensure sticky bit is set on all world-writable directories (Automated)
    - dir_perms_world_writable_sticky_bits

    ### 1.1.23 Disable Automounting (Automated)
    - service_autofs_disabled

    ## 1.2 Configure Software Updates
    ### 1.2.1 Ensure GPG keys are configured (Manual)
    # NEEDS RULE FOR SUSE

    ### 1.2.2 Ensure package manager repositories are configured (Manual)
    # NEEDS RULE -
   
    ### 1.2.3 Ensure gpgcheck is globally activated (Manual)
    - ensure_gpgcheck_globally_activated  

    ## 1.3 Configure sudo
    ### 1.3.1 Ensure sudo is installed (Automated)
    - package_sudo_installed

    ### 1.3.2 Ensure sudo commands use pty (Automated)
    # NEEDS RULE -

    ### 1.3.3 Ensure sudo log file exists (Automated)
    # NEEDS RULE -

    ## 1.4 Filesystem Integrity Checking
    ### 1.4.1 Ensure AIDE is installed (Automated)
    - package_aide_installed

    ### 1.4.2 Ensure filesystem integrity is regularly checked (Automated)
    - aide_periodic_cron_checking

    ## 1.5 Secure Boot Settings
    ### 1.5.1 Ensure bootloader password is set (Automated)
    - grub2_password
    
    ### 1.5.2 Ensure permissions on bootloader config are configured (Automated)
    #### chown root:root /boot/grub2/grub.cfg
    - file_owner_grub2_cfg
    - file_groupowner_grub2_cfg

    #### chmod og-rwx /boot/grub2/grub.cfg
    - file_permissions_grub2_cfg

    ### 1.5.3 Ensure authentication required for single user mode (Automated)
    #### ExecStart=-/usr/lib/systemd/systemd-sulogin-shell rescue
    - require_singleuser_auth

    #### ExecStart=-/usr/lib/systemd/systemd-sulogin-shell emergency
    - require_emergency_target_auth

    ## 1.6 Additional Process Hardening
    ### 1.6.1 Ensure core dumps are restricted (Automated)
    #### * hard core 0
    - disable_users_coredumps

    #### fs.suid_dumpable = 0
    - sysctl_fs_suid_dumpable

    #### ProcessSizeMax=0
    - coredump_disable_backtraces

    #### Storage=none
    - coredump_disable_storage

    ### 1.6.2 Ensure XD/NS support is enabled (Automated)
    #### No configuration required for 64-bit systems

    ### 1.6.3 Ensure address space layout randomization (ASLR) is enabled (Automated)
    - sysctl_kernel_randomize_va_space

    ### 1.6.4 Ensure prelink is disabled (Automated)
    - package_prelink_removed

    ## 1.7 Mandatory Access Control
    ### 1.7.1 Ensure Mandatory Access Control Software is Installed
    #### 1.7.1.1 Ensure AppArmor is installed (Automated)
    #### Need Rule

    #### 1.7.1.2 Ensure AppArmor is not disabled in bootloader configuration (Automated)
    #### Need Rule

    #### 1.7.1.3 Ensure all AppArmor Profiles are in enforce or complain (Automated)
    #### Need Rule

    #### 1.7.1.4 Ensure all AppArmor Profiles are enforcing (Automated)
    #### Need Rule

    ## 1.8 Warning Banners
    ### 1.8.1 Command Line Warning Baners
    #### 1.8.1.1 Ensure message of the day is configured properly (Automated)
    - banner_etc_motd

    #### 1.8.1.2 Ensure local login warning banner is configured properly (Automated)
    - banner_etc_issue

    #### 1.8.1.3 Ensure remote login warning banner is configured properly (Automated)
    # NEEDS RULE

    #### 1.8.1.4 Ensure permissions on /etc/motd are configured (Automated)
    # chmod u-x,go-wx /etc/motd
    - file_permissions_etc_motd

    #### 1.8.1.5 Ensure permissions on /etc/issue are configured (Automated)
    # chmod u-x,go-wx /etc/issue
    - file_permissions_etc_issue

    #### 1.8.1.6 Ensure permissions on /etc/issue.net are configured (Automated)
    # NEEDS RULE

    ## 1.9 Ensure updates, patches, and additional security software are installed (Manual)
    - security_patches_up_to_date

    ## 1.10 Ensure GDM is removed or login is configured (Automated)
    - package_gdm_removed
    # Opinionated selection
    - dconf_gnome_banner_enabled
    - dconf_gnome_login_banner_text

    # 2 Services
    ## 2.1 inetd Services
    ### 2.1.1 Ensure xinetd is not installed (Automated)
    - package_xinetd_removed 

    ## 2.2 Special Purpose Services
    ### 2.2.1 Time Synchronization
    #### 2.2.1.1 Ensure time synchronization is in use (Manual)
    - package_chrony_installed

    #### 2.2.1.2 Ensure systemd-timesysncd is configured (Manual)
    # This requirement is not applicable
    # This profile opts to use chrony rather than systemd-timesysncd

    #### 2.2.1.3 Ensure chrony is configured (Automated)
    - service_chronyd_enabled
    - chronyd_specify_remote_server
    - chronyd_run_as_chrony_user

    ### 2.2.2 Ensure X Window System is not installed (Automated)
    - package_xorg-x11-server-common_removed
    - xwindows_runlevel_target

    ### 2.2.3 Ensure Avahi Server is not installed (Automated)
    - package_avahi_removed
    - package_avahi-autoipd_removed

    ### 2.2.4 Ensure CUPS is not installed (Automated)
    - package_cups_removed

    ### 2.2.5 Ensure DHCP Server is not installed (Automated)
    - package_dhcp_removed

    ### 2.2.6 Ensure LDAP server is not enabled (Automated)
    - package_openldap2_removed

    ### 2.2.7 Ensure nfs-utils is not installed or nfs-server is masked (Automated)
    - package_nfs-utils_removed
    - package_nfs-kernel-server_removed
    # Opinionated selection
    # NEEDS RULE
    # - service_nfs-server_masked

    ### 2.2.8 Ensure rpcbind is not installed or rpcbind services are masked (Automated)
    - package_rpcbind_removed
    # Opinionated selection
    # NEEDS RULE
    # - service_rpcbind_masked

    ### 2.2.9 Ensure DNS Server is not installed (Automated)
    - package_bind_removed

    ### 2.2.10 Ensure FTP Server is not installed (Automated)
    - package_vsftpd_removed
    #TODO: Add other possible FTP Servers to list

    ### 2.2.11 Ensure HTTP server is not installed (Automated)
    - package_httpd_removed
    - package_nginx_removed
    - package_apache2_removed
    - package_lighthttpd_removed
    #TODO: Add other possible HTTP Servers to list

    ### 2.2.12 Ensure IMAP and POP3 server is not installed (Automated)
    - package_dovecot_removed

    ### 2.2.13 Ensure Samba is not installed (Automated)
    - package_smb_removed

    ### 2.2.14 Ensure HTTP Proxy Server is not installed (Automated)
    - package_squid_removed
    #TODO: Add other possible HTTP Proxy Servers to list

    ### 2.2.15 Ensure SNMP Server is not installed (Automated)
    - package_net-snmp_removed

    ### 2.2.16 Ensure mail transfer agent is configured for local-only mode (Automated)
    - postfix_network_listening_disabled

    ### 2.2.17 Ensure rsync is not installed or rsyncd service is masked (Automated)
    - package_rsync_removed
    # Opinionated selection
    # NEEDS RULE
    # - service_rsyncd_masked

    ### 2.2.18 Ensure NIS Server is not installed (Automated)
    - package_ypserv_removed

    ### 2.2.19 Ensure telnet-server is not installed (Automated)
    - package_telnet_removed

    ## 2.3 Service Clients
    ### 2.3.1 Ensure NIS Client is not installed (Automated)
    - package_ypbind_removed

    ### 2.3.2 Ensure rsh client is not installed (Automated)
    - package_rsh_removed

    ### 2.3.3 Ensure talk client is not installed (Automated)
    - package_talk_removed

    ### 2.3.4 Ensure telnet client is not installed (Automated)
    # Package telnet already removed in 2.2.19

    ### 2.3.5 Ensure LDAP client is not installed (Automated)
    - package_openldap2-clients_removed

    ## Ensure nonessential services are removed or masked (Manual)
    # lsof -i -P -n | grep -v "(ESTABLISHED)"
    # Needs Rule?
    # I think, it would be nice to see a list of service, that are not covered by the rules above.
    # Generate corresponding Remidiation on the fly after audit?

    # 3 Network Configuration
    ## 3.1 Disable unused network protocols
    ### 3.1.1 Disable IPv6 (Manual)
    - grub2_ipv6_disable_argument

    ### 3.1.2 Ensure wireless interfaces are disabled (Manual)
    - wireless_disable_interfaces

    ## 3.2 Network Parameters (Host Only)
    ### 3.2.1 Ensure IP forwarding is disabled (Automated)
    - sysctl_net_ipv4_ip_forward

    ### 3.2.2 Ensure packet redirect sending is disabled (Automated)
    - sysctl_net_ipv4_conf_all_send_redirects
    - sysctl_net_ipv4_conf_default_send_redirects

    ## 3.3 Network Parameters (Host and Router)
    ### 3.3.1 Ensure source routed packets are not accepted (Automated)
    - sysctl_net_ipv4_conf_all_accept_source_route
    - sysctl_net_ipv4_conf_default_accept_source_route

    ### 3.3.2 Ensure ICMP redirects are not accepted (Automated)
    - sysctl_net_ipv4_conf_all_accept_redirects
    - sysctl_net_ipv4_conf_default_accept_redirects

    ### 3.3.3 Ensure secure ICMP redirects are not accepted (Automated)
    - sysctl_net_ipv4_conf_all_secure_redirects
    - sysctl_net_ipv4_conf_default_secure_redirects

    ### 3.3.4 Ensure suspicious packets are logged (Automated)
    - sysctl_net_ipv4_conf_all_log_martians
    - sysctl_net_ipv4_conf_default_log_martians

    ### 3.3.5 Ensure broadcast ICMP requests are ignored (Automated)
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts

    ### 3.3.6 Ensure bogus ICMP responses are ignored (Automated)
    - sysctl_net_ipv4_icmp_ignore_bogus_error_responses

    ### 3.3.7 Ensure Reverse Path Filtering is enabled (Automated)
    - sysctl_net_ipv4_conf_all_rp_filter
    - sysctl_net_ipv4_conf_default_rp_filter

    ### 3.3.8 Ensure TCP SYN Cookies is enabled (Automated)
    - sysctl_net_ipv4_tcp_syncookies

    ### 3.3.9 Ensure IPv6 router advertisements are not accepted (Manual)
    - sysctl_net_ipv6_conf_all_accept_ra
    - sysctl_net_ipv6_conf_default_accept_ra

    ## 3.4 Uncommon Network Protocols
    ### 3.4.1 Ensure DCCP is disabled (Automated)
    - kernel_module_dccp_disabled

    ### 3.4.2 Ensure SCTP is disabled (Automated)
    - kernel_module_sctp_disabled

    ## 3.5 Firewall Configuration
    ### 3.5.1 Configure FirewallD
    #### 3.5.1.1 Ensure FirewallD is installed (Automated)
    - package_firewalld_installed
    - package_iptables_installed
    
    #### 3.5.1.2 Ensure nftables is not installed or stoped and masked (Automated)
    - package_nftables_removed

    # Stop and Mask Service
    # Needs Rule

    #### 3.5.1.3 Ensure firewalld service is enabled and running (Automated)
    - service_firewalld_enabled

    #### 3.5.1.4 Ensure default zone is set (Automated)
    - set_firewalld_default_zone

    #### 3.5.1.5 Ensure network interfaces are assigned to appropriate zone (Manual)
    #### Need rule
    # A list should be returned for manual remidiation

    #### 3.5.1.6 Ensure unnecessary services and ports are not accepted (Manual)
    #### NEED RULE
    # A list should be returned for manual remidiation

    ### 3.5.2 Configure nftables
    #### 3.5.2.1 Ensure nftables is installed (Automated)
    - package_nftables_installed

    #### 3.5.2.2 Ensure firewalld is not installed or stopped and masked (Automated)
    - package_firewalld_removed
    # Opinionated selection
    - service_nfs-server_disbaled
    
    #### 3.5.2.3 Ensure iptables are flushed (UnAutomated)
    #### NEED RULE
    
    #### 3.5.2.4 Ensure a table exists (Automated)
    #### NEED RULE
    
    #### 3.5.2.5 Ensure a base chain exists (Automated)
    #### NEED RULE
    
    #### 3.5.2.6 Ensure loopback traffic is configured (Automated)
    #### NEED RULE
    
    #### 3.5.2.7 Ensure outbound and established connections are configured (Automated)
    #### NEED RULE
    
    #### 3.5.2.8 Ensure default deny firewall policy (Automated)
    #### NEED RULE
    
    #### 3.5.2.9 Ensure nftables service is enabled (Automated)
    - service_nftables_enabled
    
    #### 3.5.2.11 Ensure nftables rules are permanent (Manual)
    #### NEED RULE
    
    ### 3.5.3 Configure iptables
    #### 3.5.3.1 Configure software
    ##### 3.5.3.1.1 Ensure iptables is installed (Automated)
    - package_iptables_installed

    # Ensure iptables.service is enabled and running
    - service_iptables_enabled

    ##### 3.5.3.1.2 Ensure nftables is not installed (Automated)
    - package_nftables_removed
    
    ##### 3.5.3.1.3 Ensure firewalld is not installed or masked and stoped (Automated)
    - package_firewalld_removed
    
    ### Mask Serice
    # NEEDS RULE

    #### 3.5.3.2 Configure IPv4 iptables
    ##### 3.5.3.2.1 Ensure default deny firewall policy (Automated)
    - set_iptables_default_rule
    
    ##### 3.5.3.2.2 Ensure loopback traffic is configured (Automated)
    # NEEDS RULE
    
    ##### 3.5.3.2.3 Ensure outbound and established connections are configured (Manual)
    # NEEDS RULE
    
    ##### 3.5.3.2.4 Ensure firewall rules exist for all open ports (Automated)
    # NEEDS RULE
    
    #### 3.5.3.3 Configure IPv6 iptables
    ##### 3.5.3.3.1 Ensure IPv6 default deny firewall policy (Automated)
    - set_ip6tables_default_rule
    
    ##### 3.5.3.3.2 Ensure IPv6 loopback traffic is configured (Automated)
    # NEEDS RULE
    
    ##### 3.5.3.3.3 Ensure IPv6 outbound and established connections are configured (Automated)
    # NEEDS RULE
    
    ##### 3.5.3.3.4 Ensure IPv6 firewall rules exist for all open ports (Manual)
    # NEEDS RULE

    # 4 Logging and Auditing
    ## 4.1 Configure System Accounting (auditd)
    ### 4.1.1 Ensure Auditing is enabled
    ###  4.1.1.1 Ensure auditd is installed (Automated)
    - package_audit_installed

    #### 4.1.1.2 Ensure auditd service is enabled (Automated)
    - service_auditd_enabled

    #### 4.1.1.3 Ensure auditing for processes that start prior to audit
    ####         is enabled (Automated)
    - grub2_audit_argument

    ### 4.1.2 Configure Data Retention
    #### 4.1.2.1 Ensure audit log storage size is configured (Automated)
    - auditd_data_retention_max_log_file

    #### 4.1.2.2 Ensure audit logs are not automatically deleted (Automated)
    - auditd_data_retention_max_log_file_action

    #### 4.1.2.3 Ensure system is disabled when audit logs are full (Automated)
    - var_auditd_space_left_action=email
    - auditd_data_retention_space_left_action

    ##### action_mail_acct = root
    - var_auditd_action_mail_acct=root
    - auditd_data_retention_action_mail_acct

    ##### admin_space_left_action = halt
    - var_auditd_admin_space_left_action=halt
    - auditd_data_retention_admin_space_left_action

   #### 4.1.2.4 Ensure audit_backlog_limit is sufficient (Automated)
    - grub2_audit_backlog_limit_argument

    ### 4.1.3 Ensure events that modify date and time information
    ###       are collected (Automated)
    #### adjtimex
    - audit_rules_time_adjtimex

    #### settimeofday
    - audit_rules_time_settimeofday

    #### stime
    - audit_rules_time_stime

    #### clock_settime
    - audit_rules_time_clock_settime

    #### -w /etc/localtime -p wa
    - audit_rules_time_watch_localtime

    ### 4.1.4 Ensure events that modify user/group information are
    ###       collected (Automated)
    - audit_rules_usergroup_modification_passwd
    - audit_rules_usergroup_modification_group
    - audit_rules_usergroup_modification_gshadow
    - audit_rules_usergroup_modification_shadow
    - audit_rules_usergroup_modification_opasswd


    ### 4.1.5 Ensure events that modify the system's network
    ###       enironment are collected (Automated)
    - audit_rules_networkconfig_modification

    ### 4.1.6 Ensure events that modify the system's Mandatory
    ###       Access Control are collected (Automated)
    #### -w /etc/selinux/ -p wa
    - audit_rules_mac_modification

    #### -w /usr/share/selinux/ -p wa
    # NEED RULE - https://github.com/ComplianceAsCode/content/issues/5264

    ### 4.1.7 Ensure login and logout events are collected (Automated)
    - audit_rules_login_events_faillock
    - audit_rules_login_events_lastlog

    ### 4.1.8 Ensure session initiation information is collected (Automated)
    - audit_rules_session_events

    ### 4.1.9 Ensure discretionary access control permission modification
    ###       events are collected (Automated)
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

    ### 4.1.10 Ensure unsuccessful unauthorized file access attempts are
    ###        collected (Automated)
    - audit_rules_unsuccessful_file_modification_creat
    - audit_rules_unsuccessful_file_modification_open
    - audit_rules_unsuccessful_file_modification_openat
    - audit_rules_unsuccessful_file_modification_truncate
    - audit_rules_unsuccessful_file_modification_ftruncate
    # Opinionated selection
    - audit_rules_unsuccessful_file_modification_open_by_handle_at

    ### 4.1.11 Ensure use of privileged commands is collected (Automated)
    - audit_rules_privileged_commands

    ### 4.1.12 Ensure successful file system mounts are collected (Automated)
    - audit_rules_media_export

    ### 4.1.13 Ensure file deletion events by users are collected
    ###        (Automated)
    - audit_rules_file_deletion_events_unlink
    - audit_rules_file_deletion_events_unlinkat
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_renameat
    # Opinionated selection
    - audit_rules_file_deletion_events_rmdir

    ### 4.1.14 Ensure changes to system administration scope
    ###       (sudoers) is collected (Automated)
    - audit_rules_sysadmin_actions

    ### 4.1.15 Ensure system administrator actions (sudolog) are
    ###        collected (Automated)
    ### NEED RULE

    ### 4.1.16 Ensure kernel module loading and unloading is collected
    ###        (Automated)
    -  audit_rules_kernel_module_loading

    ### 4.1.17 Ensure the audit configuration is immutable (Automated)
    - audit_rules_immutable

    ## 4.2 Configure Logging
    ### 4.2.1 Configure rsyslog
    #### 4.2.1.1 Ensure rsyslog is installed (Automated)
    - package_rsyslog_installed

    #### 4.2.1.2 Ensure rsyslog Service is enabled (Automated)
    - service_rsyslog_enabled

    #### 4.2.1.3 Ensure rsyslog default file permissions configured (Automated)
    - rsyslog_files_groupownership
    - rsyslog_files_ownership
    - rsyslog_files_permissions

    #### 4.2.1.4 Ensure logging is configured (Manual)
    ### Manual Remideiation required.

    #### 4.2.1.5 Ensure rsyslog is configured to send logs to a remote
    ####         log host (Automated)
    - rsyslog_remote_loghost

    #### 4.2.1.6 Ensure remote rsyslog messages are only accepted on
    ####         designated log hosts (Manual) 
    #### NEED RULE

    ### 4.2.2 Configure journald
    #### 4.2.2.1 Ensure journald is configured to send logs to
    ####         rsyslog (Automated)
    #### NEED RULE

    #### 4.2.2.2 Ensure journald is configured to compress large
    ####         log files (Automated)
    #### NEED RULE

    #### 4.2.2.3 Ensure journald is configured to write logfiles to
    ####         persistent disk (Automated)
    #### NEED RULE

    ### 4.2.3 Ensure permissions on all logfiles are configured (Automated)
    ### NEED RULE

    ### 4.2.4 Ensure logrotate is conifgured (Manual)
    - ensure_logrotate_activated

    # 5 Access, Authentication and Authorization
    ## 5.1 Configure time-based job schedulers
    ### 5.1.1 Ensure cron daemon is enabled (Automated)
    - service_cron_enabled

    ### 5.1.2 Ensure permissions on /etc/crontab are configured (Automated)
    # chown root:root /etc/crontab
    - file_owner_crontab
    - file_groupowner_crontab
    # chmod 600 /etc/crontab
    - file_permissions_crontab

    ### 5.1.3 Ensure permissions on /etc/cron.hourly are configured (Automated)
    # chown root:root /etc/cron.hourly
    - file_owner_cron_hourly
    - file_groupowner_cron_hourly
    # chmod 700 /etc/cron.hourly
    - file_permissions_cron_hourly

    ### 5.1.4 Ensure permissions on /etc/cron.daily are configured (Automated)
    # chown root:root /etc/cron.daily
    - file_owner_cron_daily
    - file_groupowner_cron_daily
    # chmod 700 /etc/cron.daily
    - file_permissions_cron_daily

    ### 5.1.5 Ensure permissions on /etc/cron.weekly are configured (Automated)
    # chown root:root /etc/cron.weekly
    - file_owner_cron_weekly
    - file_groupowner_cron_weekly
    # chmod 700 /etc/cron.weekly
    - file_permissions_cron_weekly

    ### 5.1.6 Ensure permissions on /etc/cron.monthly are configured (Automated)
    # chown root:root /etc/cron.monthly
    - file_owner_cron_monthly
    - file_groupowner_cron_monthly
    # chmod og-rwx /etc/cron.monthly
    - file_permissions_cron_monthly

    ### 5.1.7 Ensure permissions on /etc/cron.d are configured (Automated)
    # chown root:root /etc/cron.d
    - file_owner_cron_d
    - file_groupowner_cron_d
    # chmod 700 /etc/cron.d
    - file_permissions_cron_d

    ### 5.1.8 Ensure cron is restricted to authorized users (Automated)
    # chown root:root /etc/cron.deny
    - file_owner_cron_deny
    - file_groupowner_cron_deny
    
    # chmod 600 /etc/cron.deny
    - file_permissions_cron_deny

    # chown root:root /etc/cron.allow
    - file_owner_cron_allow
    - file_groupowner_cron_allow
    
    # chmod 600 /etc/cron.allow
    - file_permissions_cron_allow
    
    ### 5.1.9 Ensure at is restricted to authorized users (Automated)
    ### NEED RULE

    ## 5.2 SSH Server Configuration
    ### 5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured (Automated)
    # chown root:root /etc/ssh/sshd_config
    - file_owner_sshd_config
    - file_groupowner_sshd_config

    # chmod og-rwx /etc/ssh/sshd_config
    - file_permissions_sshd_config

    ### 5.2.2 Ensure permissions on SSH private host key files are
    ###       configured (Automated)
    # TO DO: The rule sets to 640, but benchmark wants 600
    - file_permissions_sshd_private_key
    # TO DO: check owner of private keys in /etc/ssh is root:root

    ### 5.2.3 Ensure permissions on SSH public host key files are configured
    ###      (Automated)
    - file_permissions_sshd_pub_key
    # TO DO: check owner of pub keys in /etc/ssh is root:root

    ### 5.2.4 Ensure SSH access is limited (Automated)
    ### NEED RULE

    ### 5.2.5 Ensure SSH LogLevel is appropriate (Automated)
    - sshd_set_loglevel_info

    ### 5.2.6 Ensure SSH X11 forward is diabled (Automated)
    # - sshd_disable_x11_forwarding waiting until my pull request is merged

    ### 5.2.7 Ensure SSH MaxAuthTries is set to 4 or less (Automated)
    - sshd_max_auth_tries_value=4
    - sshd_set_max_auth_tries

    ### 5.2.8 Ensure SSH IgnoreRhosts is enabled (Automated)
    - sshd_disable_rhosts

    ### 5.2.9 Ensure SSH HostbasedAuthentication is disabled (Automated)
    - disable_host_auth

    ### 5.2.10 Ensure SSH root login is disabled (Automated)
    - sshd_disable_root_login

    ### 5.2.11 Ensure SSH PermitEmptyPasswords is disabled (Automated)
    - sshd_disable_empty_passwords

    ### 5.2.12 Ensure SSH PermitUserEnvironment is disabled (Automated)
    - sshd_do_not_permit_user_env

    ### 5.2.13 Ensure only strong Ciphers are used (Automated)
    - sshd_use_strong_ciphers

    ### 5.2.14 Ensure only strong MAC algorithms are used (Automated)
    - sshd_use_strong_macs

    ### 5.2.15 Ensure only strong Key Exchange algorithms are used (Automated)
    ### NEED RULE - ssh_use_strong_kex

    ### 5.2.16 Ensure SSH Idle Timeout Interval is configured (Automated)
    # ClientAliveInterval 300
    - sshd_idle_timeout_value=5_minutes
    - sshd_set_idle_timeout

    # ClientAliveCountMax 0
    - sshd_set_keepalive

    ### 5.2.17 Ensure SSH LoginGraceTime is set to one minute
    ###        or less (Automated)    
    ### NEED RULE

    ### 5.2.18 Ensure SSH warning banner is configured (Automated)
    - sshd_enable_warning_banner

    ### 5.2.19 Ensure SSH PAM is enabled (Automated)
    ### NEED RULE

    ### 5.2.20 Ensure SSH AllowTcpForwarding is disabled (Automated)
    - sshd_disable_tcp_forwarding
    
    ### 5.2.21 Ensure SSH MaxStartups is configured (Automated)
    ### NEED RULE

    ### 5.2.22 Ensure SSH MaxSessions is set to 4 or less (Automated)
    ### NEED RULE

    ## 5.3 Configure PAM
    ### 5.3.1 Ensure password creation requirements are configured (Automated)
    - accounts_password_pam_retry
    - var_password_pam_minlen=14
    - accounts_password_pam_minlen
    - var_password_pam_minclass=4
    - accounts_password_pam_minclass
    
    ### 5.3.2 Ensure lockout for failed password attempts is
    ###       configured (Automated)
    - var_accounts_passwords_pam_faillock_unlock_time=900
    - var_accounts_passwords_pam_faillock_deny=5
    - accounts_passwords_pam_faillock_unlock_time
    - accounts_passwords_pam_faillock_deny

    ### 5.3.3 Ensure password reuse is limited (Automated)
    - var_password_pam_unix_remember=5
    - accounts_password_pam_unix_remembe

    ## 5.4 User Accounts and Environment
    ### 5.4.1 Set Shadow Password Suite Parameters
    #### 5.4.1.1 Ensure password hasing algorithm is SHA-512 (Automated)
    - set_password_hashing_algorithm_systemauth

    #### 5.4.1.2 Ensure password expiration is 365 days or less (Automated)
    - var_accounts_maximum_age_login_defs=365
    - accounts_maximum_age_login_defs

    #### 5.4.1.3 Ensure minimum days between password changes is 7
    ####         or more (Automated)
    - var_accounts_minimum_age_login_defs=7
    - accounts_minimum_age_login_defs

    #### 5.4.1.3 Ensure password expiration warning days is
    ####         7 or more (Automated)
    - var_accounts_password_warn_age_login_defs=7
    - accounts_password_warn_age_login_defs

    #### 5.4.1.4 Ensure inactive password lock is 30 days or less (Automated)
    - var_account_disable_post_pw_expiration=30
    - account_disable_post_pw_expiration

    #### 5.4.1.5 Ensure all users last password change date is
    ####         in the past (Automated)
    #### NEEDS RULE

    ### 5.4.2 Ensure system accounts are secured (Automated)
    - no_shelllogin_for_systemaccounts

    ### 5.4.3 Ensure default group for the root account is
    ###       GID 0 (Automated)
    ### NEED RULE

    ### 5.4.4 Ensure default user shell timeout is 900 seconds
    ###       or less (Automated)
    - var_accounts_tmout=15_min
    - accounts_tmout

    ### 5.4.5 Ensure default user mask is 027 or more restrictive (Automated)
    - var_accounts_user_umask=027
    - accounts_umask_etc_bashrc
    - accounts_umask_etc_profile
    

    ## 5.5 Ensure root login is restricted to system console (Manual)
    - securetty_root_login_console_only
    - no_direct_root_logins


    ## 5.6 Ensure access to the su command is restricted (Automated)
    ## NEED RULE

    # 6 System Maintenance
    ## 6.1 System File Permissions
    ### 6.1.1 Audit system file permissions (Manual)
    - rpm_verify_permissions
    - rpm_verify_ownership

    ### 6.1.2 Ensure permissions on /etc/passwd are configured (Automated)
    # chown root:root /etc/passwd
    - file_owner_etc_passwd
    - file_groupowner_etc_passwd

    # chmod 644 /etc/passwd
    - file_permissions_etc_passwd

    ### 6.1.3 Ensure permissions on /etc/shadow are configured (Automated)
    # chown root:root /etc/shadow
    - file_owner_etc_shadow
    - file_groupowner_etc_shadow

    # chmod 600 /etc/shadow
    - file_permissions_etc_shadow

    ### 6.1.4 Ensure permissions on /etc/group are configured (Automated)
    # chown root:root /etc/group
    - file_owner_etc_group
    - file_groupowner_etc_group

    # chmod 644 /etc/group
    - file_permissions_etc_group

    ### 6.1.5 Ensure permissions on /etc/passwd- are configured (Automated)
    # chown root:root /etc/passwd-
    - file_owner_backup_etc_passwd
    - file_groupowner_backup_etc_passwd

    # chmod 600 /etc/passwd-
    - file_permissions_backup_etc_passwd
    
    ### 6.1.6 Ensure permissions on /etc/shadow- are configured (Automated)
    # chown root:root /etc/shadow-
    - file_owner_backup_etc_shadow-
    - file_groupowner_backup_etc_shadow-

    # chmod 600 /etc/shadow
    - file_permissions_backup_etc_shadow-

    ### 6.1.7 Ensure permissions on /etc/group- are configured (Automated)
    # chown root:root /etc/group-
    - file_owner_backup_etc_group
    - file_groupowner_backup_etc_group

    # chmod 0644 /etc/group-
    - file_permissions_backup_etc_group

    ### 6.1.8 Ensure no world writable files exist (Automated)
    - file_permissions_unauthorized_world_writable

    ### 6.1.9 Ensure no unowned files or directories exist (Automated)
    - no_files_unowned_by_user

    ### 6.1.10 Ensure no ungrouped files or directories exist (Automated)
    - file_permissions_ungroupowned

    ### 6.1.11 Audit SUID executables (Manual)
    - file_permissions_unauthorized_suid

    ### 6.1.12 Audit SGID executables (Manual)
    - file_permissions_unauthorized_sgid

    ## 6.2 User and Group Settings
    ### 6.2.1 Ensure accounts in /etc/passwd use shadowed passwords (Automated)
    ### NEED RULE

    ### 6.2.2 Ensure /etc/shadow password fields are not empty (Automated)
    ### NEED RULE

    ### 6.2.3 Ensure root is the only UID 0 account (Automated)
    ### NEED RULE

    ### 6.2.4 Ensure root PATH Integrity (Automated)
    ### NEED RULE

    ### 6.2.5 Ensure all users' home directories exist (Automated) 
    ### NEED RULE

    ### 6.2.6 Ensure users' home directories permissions are 750 or more
    ### restrictive (Automated)
    - file_permissions_home_dirs

    ### 6.2.7 Ensure users own their home directories (Automated)
    - file_groupownership_home_directories

    ### 6.2.8 Ensure users' dot files are not group or world writable (Automated)
    ### NEED RULE

    ### 6.2.9 Ensure no users have .forward files (Automated)
    ### NEED RULE

    ### 6.2.10 Ensure no users have .netrc files (Automated)
    - no_netrc_files

    ### 6.2.11 Ensure users' .netrc Files are not group or world accessible (Automated)
    ### NEED RULE

    ### 6.2.12 Ensure no users have .rhosts files (Automated)
    - no_rsh_trust_files

    ### 6.2.13 Ensure all groups in /etc/passwd exist in /etc/group (Automated)
    ### NEED RULE

    ### 6.2.14 Ensure no duplicate UIDs exist (Automated)
    ### NEED RULE

    ### 6.2.15 Ensure no duplicate GIDs exist (Automated)
    ### NEED RULE

    ### 6.2.16 Ensure no duplicate user names exist (Automated)
    ### NEED RULE

    ### 6.2.17 Ensure no duplicate group names exist (Automated)
    ### NEED RULE

    ### 6.2.18 Ensure shadow group is empty (Automated)
    ### NEED RULE