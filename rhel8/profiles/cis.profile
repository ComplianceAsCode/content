documentation_complete: true

metadata:
    version: 1.0.0
    SMEs:
        - vojtapolasek
        - yuumasato

reference: https://www.cisecurity.org/benchmark/red_hat_linux/

title: 'CIS Red Hat Enterprise Linux 8 Benchmark'

description: |-
    This profile defines a baseline that aligns to the Center for Internet Security®
    Red Hat Enterprise Linux 8 Benchmark™, v1.0.0, released 09-30-2019.

    This profile includes Center for Internet Security®
    Red Hat Enterprise Linux 8 CIS Benchmarks™ content.

selections:
    # Necessary for dconf rules
    - dconf_db_up_to_date

    ### Partitioning
    - mount_option_home_nodev

    ## 1.1 Filesystem Configuration

    ### 1.1.1 Disable unused filesystems

    #### 1.1.1.1 Ensure mounting cramfs filesystems is disabled (Scored)
    - kernel_module_cramfs_disabled

    #### 1.1.1.2 Ensure mounting of vFAT filesystems is limited (Not Scored)


    #### 1.1.1.3 Ensure mounting of squashfs filesystems is disabled (Scored)
    - kernel_module_squashfs_disabled

    #### 1.1.1.4 Ensure mounting of udf filesystems is disabled (Scored)
    - kernel_module_udf_disabled

    ### 1.1.2 Ensure /tmp is configured (Scored)
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

    ### 1.1.23 Disable USB Storage (Scored)
    - kernel_module_usb-storage_disabled

    ## 1.2 Configure Software Updates

    ### 1.2.1 Ensure Red Hat Subscription Manager connection is configured (Not Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5218

    ### 1.2.2 Disable the rhnsd Daemon (Not Scored)
    - service_rhnsd_disabled

    ### 1.2.3 Ensure GPG keys are configured (Not Scored)
    - ensure_redhat_gpgkey_installed

    ### 1.2.4 Ensure gpgcheck is globally activated (Scored)
    - ensure_gpgcheck_globally_activated

    ### 1.2.5 Ensure package manager repositories are configured (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5219

    ## 1.3 Configure sudo

    ### 1.3.1 Ensure sudo is installed (Scored)
    - package_sudo_installed

    ### 1.3.2 Ensure sudo commands use pty (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5220

    ### 1.3.3 Ensure sudo log file exists (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5221

    ## 1.4 Filesystem Integrity Checking

    ### 1.4.1 Ensure AIDE is installed (Scored)
    - package_aide_installed

    ### 1.4.2 Ensure filesystem integrity is regularly checked (Scored)
    - aide_periodic_cron_checking

    ## Secure Boot Settings

    ### 1.5.1 Ensure permissions on bootloader config are configured (Scored)
    #### chown root:root /boot/grub2/grub.cfg
    - file_owner_grub2_cfg
    - file_groupowner_grub2_cfg

    #### chmod og-rwx /boot/grub2/grub.cfg
    - file_permissions_grub2_cfg

    #### chown root:root /boot/grub2/grubenv
    # NEED RULE - https://github.com/ComplianceAsCode/content/issues/5222

    #### chmod og-rwx /boot/grub2/grubenv
    # NEED RULE - https://github.com/ComplianceAsCode/content/issues/5222

    ### 1.5.2 Ensure bootloader password is set (Scored)
    - grub2_password

    ### 1.5.3 Ensure authentication required for single user mode (Scored)
    #### ExecStart=-/usr/lib/systemd/systemd-sulogin-shell rescue
    - require_singleuser_auth

    #### ExecStart=-/usr/lib/systemd/systemd-sulogin-shell emergency
    - require_emergency_target_auth

    ## 1.6 Additional Process Hardening

    ### 1.6.1 Ensure core dumps are restricted (Scored)
    #### * hard core 0
    - disable_users_coredumps

    #### fs.suid_dumpable = 0
    - sysctl_fs_suid_dumpable

    #### ProcessSizeMax=0
    - coredump_disable_backtraces

    #### Storage=none
    - coredump_disable_storage

    ### 1.6.2 Ensure address space layout randomization (ASLR) is enabled
    - sysctl_kernel_randomize_va_space

    ## 1.7 Mandatory Access Control

    ### 1.7.1 Configure SELinux

    #### 1.7.1.1 Ensure SELinux is installed (Scored)
    - package_libselinux_installed

    #### 1.7.1.2 Ensure SELinux is not disabled in bootloader configuration (Scored)
    - grub2_enable_selinux

    #### 1.7.1.3 Ensure SELinux policy is configured (Scored)
    - var_selinux_policy_name=targeted
    - selinux_policytype
 
    #### 1.7.1.4 Ensure the SELinux state is enforcing (Scored)
    - var_selinux_state=enforcing
    - selinux_state

    #### 1.7.1.5 Ensure no unconfied services exist (Scored)
    - selinux_confinement_of_daemons

    #### 1.7.1.6 Ensure SETroubleshoot is not installed (Scored)
    - package_setroubleshoot_removed

    #### 1.7.1.7 Ensure the MCS Translation Service (mcstrans) is not installed (Scored)
    - package_mcstrans_removed

    ## Warning Banners

    ### 1.8.1 Command Line Warning Baners

    #### 1.8.1.1 Ensure message of the day is configured properly (Scored)
    - banner_etc_motd

    #### 1.8.1.2 Ensure local login warning banner is configured properly (Scored)
    - banner_etc_issue

    #### 1.8.1.3 Ensure remote login warning banner is configured properly (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5225

    #### 1.8.1.4 Ensure permissions on /etc/motd are configured (Scored)
    # chmod u-x,go-wx /etc/motd
    - file_permissions_etc_motd

    #### 1.8.1.5 Ensure permissions on /etc/issue are configured (Scored)
    # chmod u-x,go-wx /etc/issue
    - file_permissions_etc_issue

    #### 1.8.1.6 Ensure permissions on /etc/issue.net are configured (Scored)
    # Previously addressed via 'rpm_verify_permissions' rule

    ### 1.8.2 Ensure GDM login banner is configured (Scored)
    #### banner-message-enable=true
    - dconf_gnome_banner_enabled

    #### banner-message-text='<banner message>'
    - dconf_gnome_login_banner_text

    ## 1.9 Ensure updates, patches, and additional security software are installed (Scored)
    - security_patches_up_to_date

    ## 1.10 Ensure system-wide crypto policy is not legacy (Scored)
    - var_system_crypto_policy=future
    - configure_crypto_policy

    ## 1.11 Ensure system-wide crytpo policy is FUTURE or FIPS (Scored)
    # Previously addressed via 'configure_crypto_policy' rule

    # Services

    ## 2.1 inetd Services

    ### 2.1.1 Ensure xinetd is not installed (Scored)
    - package_xinetd_removed

    ## 2.2 Special Purpose Services

    ### 2.2.1 Time Synchronization

    #### 2.2.1.1 Ensure time synchronization is in use (Not Scored)
    - package_chrony_installed

    #### 2.2.1.2 Ensure chrony is configured (Scored)
    - service_chronyd_enabled
    - chronyd_specify_remote_server
    - chronyd_run_as_chrony_user

    ### 2.2.2 Ensure X Window System is not installed (Scored)
    - package_xorg-x11-server-common_removed
    - xwindows_runlevel_target

    ### 2.2.3 Ensure rsync service is not enabled (Scored)
    - service_rsyncd_disabled

    ### 2.2.4 Ensure Avahi Server is not enabled (Scored)
    - service_avahi-daemon_disabled

    ### 2.2.5 Ensure SNMP Server is not enabled (Scored)
    - service_snmpd_disabled

    ### 2.2.6 Ensure HTTP Proxy Server is not enabled (Scored)
    - package_squid_removed

    ### 2.2.7 Ensure Samba is not enabled (Scored)
    - service_smb_disabled

    ### 2.2.8 Ensure IMAP and POP3 server is not enabled (Scored)
    - service_dovecot_disabled

    ### 2.2.9 Ensure HTTP server is not enabled (Scored)
    - service_httpd_disabled

    ### 2.2.10 Ensure FTP Server is not enabled (Scored)
    - service_vsftpd_disabled

    ### 2.2.11 Ensure DNS Server is not enabled (Scored)
    - service_named_disabled

    ### 2.2.12 Ensure NFS is not enabled (Scored)
    - service_nfs_disabled

    ### 2.2.13 Ensure RPC is not enabled (Scored)
    - service_rpcbind_disabled

    ### 2.2.14 Ensure LDAP service is not enabled (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5231

    ### 2.2.15 Ensure DHCP Server is not enabled (Scored)
    - service_dhcpd_disabled

    ### 2.2.16 Ensure CUPS is not enabled (Scored)
    - service_cups_disabled

    ### 2.2.17 Ensure NIS Server is not enabled (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5232

    ### 2.2.18 Ensure mail transfer agent is configured for
    ###        local-only mode (Scored)
    - postfix_network_listening_disabled

    ## 2.3 Service Clients

    ### 2.3.1 Ensure NIS Client is not installed (Scored)
    - package_ypbind_removed

    ### 2.3.2 Ensure telnet client is not installed (Scored)
    - package_telnet_removed

    ### Ensure LDAP client is not installed
    - package_openldap-clients_removed

    # 3 Network Configuration

    ## 3.1 Network Parameters (Host Only)

    ### 3.1.1 Ensure IP forwarding is disabled (Scored)
    #### net.ipv4.ip_forward = 0
    - sysctl_net_ipv4_ip_forward

    #### net.ipv6.conf.all.forwarding = 0
    - sysctl_net_ipv6_conf_all_forwarding

    ### 3.1.2 Ensure packet redirect sending is disabled (Scored)
    #### net.ipv4.conf.all.send_redirects = 0
    - sysctl_net_ipv4_conf_all_send_redirects

    #### net.ipv4.conf.default.send_redirects = 0
    - sysctl_net_ipv4_conf_default_send_redirects

    ## 3.2 Network Parameters (Host and Router)

    ### 3.2.1 Ensure source routed packets are not accepted (Scored)
    #### net.ipv4.conf.all.accept_source_route = 0
    - sysctl_net_ipv4_conf_all_accept_source_route

    #### net.ipv4.conf.default.accept_source_route = 0
    - sysctl_net_ipv4_conf_default_accept_source_route

    #### net.ipv6.conf.all.accept_source_route = 0
    - sysctl_net_ipv6_conf_all_accept_source_route

    #### net.ipv6.conf.default.accept_source_route = 0
    - sysctl_net_ipv6_conf_default_accept_source_route

    ### 3.2.2 Ensure ICMP redirects are not accepted (Scored)
    #### net.ipv4.conf.all.accept_redirects = 0
    - sysctl_net_ipv4_conf_all_accept_redirects

    #### net.ipv4.conf.default.accept_redirects
    - sysctl_net_ipv4_conf_default_accept_redirects

    #### net.ipv6.conf.all.accept_redirects = 0
    - sysctl_net_ipv6_conf_all_accept_redirects

    #### net.ipv6.conf.defaults.accept_redirects = 0
    - sysctl_net_ipv6_conf_default_accept_redirects

    ### 3.2.3 Ensure secure ICMP redirects are not accepted (Scored)
    #### net.ipv4.conf.all.secure_redirects = 0
    - sysctl_net_ipv4_conf_all_secure_redirects

    #### net.ipv4.cof.default.secure_redirects = 0
    - sysctl_net_ipv4_conf_default_secure_redirects

    ### 3.2.4 Ensure suspicious packets are logged (Scored)
    #### net.ipv4.conf.all.log_martians = 1
    - sysctl_net_ipv4_conf_all_log_martians

    #### net.ipv4.conf.default.log_martians = 1
    - sysctl_net_ipv4_conf_default_log_martians

    ### 3.2.5 Ensure broadcast ICMP requests are ignored (Scored)
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts

    ### 3.2.6 Ensure bogus ICMP responses are ignored (Scored)
    - sysctl_net_ipv4_icmp_ignore_bogus_error_responses

    ### 3.2.7 Ensure Reverse Path Filtering is enabled (Scored)
    #### net.ipv4.conf.all.rp_filter = 1
    - sysctl_net_ipv4_conf_all_rp_filter
    
    #### net.ipv4.conf.default.rp_filter = 1
    - sysctl_net_ipv4_conf_default_rp_filter

    ### 3.2.8 Ensure TCP SYN Cookies is enabled (Scored)
    - sysctl_net_ipv4_tcp_syncookies

    ### 3.2.9 Ensure IPv6 router advertisements are not accepted (Scored)
    #### net.ipv6.conf.all.accept_ra = 0
    - sysctl_net_ipv6_conf_all_accept_ra

    #### net.ipv6.conf.default.accept_ra = 0
    - sysctl_net_ipv6_conf_default_accept_ra

    ## 3.3 Uncommon Network Protocols

    ### 3.3.1 Ensure DCCP is disabled (Scored)
    - kernel_module_dccp_disabled

    ### Ensure SCTP is disabled (Scored)
    - kernel_module_sctp_disabled

    ### 3.3.3 Ensure RDS is disabled (Scored)
    - kernel_module_rds_disabled

    ### 3.3.4 Ensure TIPC is disabled (Scored)
    - kernel_module_tipc_disabled

    ## 3.4 Firewall Configuration

    ### 3.4.1 Ensure Firewall software is installed

    #### 3.4.1.1 Ensure a Firewall package is installed (Scored)
    ##### firewalld
    - package_firewalld_installed

    ##### nftables
    #NEED RULE - https://github.com/ComplianceAsCode/content/issues/5237

    ##### iptables
    #- package_iptables_installed

    ### 3.4.2 Configure firewalld

    #### 3.4.2.1 Ensure firewalld service is enabled and running (Scored)
    - service_firewalld_enabled

    #### 3.4.2.2 Ensure iptables is not enabled (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5238

    #### 3.4.2.3 Ensure nftables is not enabled (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5239

    #### 3.4.2.4 Ensure default zone is set (Scored)
    - set_firewalld_default_zone

    #### 3.4.2.5 Ensure network interfaces are assigned to
    ####         appropriate zone (Not Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5240

    #### 3.4.2.6 Ensure unnecessary services and ports are not
    ####         accepted (Not Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5241

    ### 3.4.3 Configure nftables
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5242

    #### 3.4.3.1 Ensure iptables are flushed (Not Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5243

    #### 3.4.3.2 Ensure a table exists (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5244

    #### 3.4.3.3 Ensure base chains exist (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5245

    #### 3.4.3.4 Ensure loopback traffic is configured (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5246

    #### 3.4.3.5 Ensure outbound and established connections are
    ####         configured (Not Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5247

    #### 3.4.3.6 Ensure default deny firewall policy (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5248

    #### 3.4.3.7 Ensure nftables service is enabled (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5249

    #### 3.4.3.8 Ensure nftables rules are permanent (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5250

    ### 3.4.4 Configure iptables

    #### 3.4.4.1 Configure IPv4 iptables
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5251

    ##### 3.4.4.1.1 Ensure default deny firewall policy (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5252

    ##### 3.4.4.1.2 Ensure loopback traffic is configured (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5253

    ##### 3.4.4.1.3 Ensure outbound and established connections are
    #####           configured (Not Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5254

    ##### 3.4.4.1.4 Ensure firewall rules exist for all open ports (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5255

    #### 3.4.4.2 Configure IPv6 ip6tables
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5256

    ##### 3.4.4.2.1 Ensure IPv6 default deny firewall policy (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5257

    ##### 3.4.4.2.2 Ensure IPv6 loopback traffic is configured (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5258

    ##### 3.4.4.2.3 Ensure IPv6 outbound and established connections are
    #####           configured (Not Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5260

    ## 3.5 Ensure wireless interfaces are disabled (Scored)
    - wireless_disable_interfaces

    ## 3.6 Disable IPv6 (Not Scored)
    - kernel_module_ipv6_option_disabled

    # Logging and Auditing

    ## 4.1 Configure System Accounting (auditd)

    ### 4.1.1 Ensure auditing is enabled

    #### 4.1.1.1 Ensure auditd is installed (Scored)
    - package_audit_installed

    #### 4.1.1.2 Ensure auditd service is enabled (Scored)
    - service_auditd_enabled

    #### 4.1.1.3 Ensure auditing for processes that start prior to audit
    ####         is enabled (Scored)
    - grub2_audit_argument

    #### 4.1.1.4 Ensure audit_backlog_limit is sufficient (Scored)
    - grub2_audit_backlog_limit_argument

    ### 4.1.2 Configure Data Retention

    #### 4.1.2.1 Ensure audit log storage size is configured (Scored)
    - auditd_data_retention_max_log_file

    #### 4.1.2.2 Ensure audit logs are not automatically deleted (Scored)
    - auditd_data_retention_max_log_file_action

    #### 4.1.2.3 Ensure system is disabled when audit logs are full (Scored)
    - var_auditd_space_left_action=email
    - auditd_data_retention_space_left_action

    ##### action_mail_acct = root
    - var_auditd_action_mail_acct=root
    - auditd_data_retention_action_mail_acct

    ##### admin_space_left_action = halt
    - var_auditd_admin_space_left_action=halt
    - auditd_data_retention_admin_space_left_action 

    ### 4.1.3 Ensure changes to system administration scope
    ###       (sudoers) is collected (Scored)
    - audit_rules_sysadmin_actions

    ### 4.1.4 Ensure login and logout events are collected (Scored)
    - audit_rules_login_events_faillock
    - audit_rules_login_events_lastlog

    ### 4.1.5 Ensure session initiation information is collected (Scored)
    - audit_rules_session_events

    ### 4.1.6 Ensure events that modify date and time information
    ###       are collected (Scored)
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

    ### 4.1.7 Ensure events that modify the system's Mandatory
    ###       Access Control are collected (Scored)
    #### -w /etc/selinux/ -p wa
    - audit_rules_mac_modification

    #### -w /usr/share/selinux/ -p wa
    # NEED RULE - https://github.com/ComplianceAsCode/content/issues/5264

    ### 4.1.8 Ensure events that modify the system's network
    ###       enironment are collected (Scored)
    - audit_rules_networkconfig_modification

    ### 4.1.9 Ensure discretionary access control permission modification
    ###       events are collected (Scored)
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
    ###        collected (Scored)
    - audit_rules_unsuccessful_file_modification_creat
    - audit_rules_unsuccessful_file_modification_open
    - audit_rules_unsuccessful_file_modification_openat
    - audit_rules_unsuccessful_file_modification_truncate
    - audit_rules_unsuccessful_file_modification_ftruncate
    # Opinionated selection
    - audit_rules_unsuccessful_file_modification_open_by_handle_at

    ### 4.1.11 Ensure events that modify user/group information are
    ###        collected (Scored)
    - audit_rules_usergroup_modification_passwd
    - audit_rules_usergroup_modification_group
    - audit_rules_usergroup_modification_gshadow
    - audit_rules_usergroup_modification_shadow
    - audit_rules_usergroup_modification_opasswd

    ### 4.1.12 Ensure successful file system mounts are collected (Scored)
    - audit_rules_media_export

    ### 4.1.13 Ensure use of privileged commands is collected (Scored)
    - audit_rules_privileged_commands

    ### 4.1.14 Ensure file deletion events by users are collected
    ###        (Scored)
    - audit_rules_file_deletion_events_unlink
    - audit_rules_file_deletion_events_unlinkat
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_renameat
    # Opinionated selection
    - audit_rules_file_deletion_events_rmdir

    ### 4.1.15 Ensure kernel module loading and unloading is collected
    ###        (Scored)
    - audit_rules_kernel_module_loading

    ### 4.1.16 Ensure system administrator actions (sudolog) are
    ###        collected (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5516

    ### 4.1.17 Ensure the audit configuration is immutable (Scored)
    - audit_rules_immutable

    ## 4.2 Configure Logging

    ### 4.2.1 Configure rsyslog

    #### 4.2.1.1 Ensure rsyslog is installed (Scored)
    - package_rsyslog_installed

    #### 4.2.1.2 Ensure rsyslog Service is enabled (Scored)
    - service_rsyslog_enabled

    #### 4.2.1.3 Ensure rsyslog default file permissions configured (Scored)
    - rsyslog_files_permissions

    #### 4.2.1.4 Ensure logging is configured (Not Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5519

    #### 4.2.1.5 Ensure rsyslog is configured to send logs to a remote
    ####         log host (Scored)   
    - rsyslog_remote_loghost

    #### 4.2.1.6 Ensure remote rsyslog messages are only accepted on
    ####         designated log hosts (Not Scored)
    - rsyslog_nolisten

    ### 4.2.2 Configure journald

    #### 4.2.2.1 Ensure journald is configured to send logs to
    ####         rsyslog (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5520

    #### 4.2.2.2 Ensure journald is configured to compress large
    ####         log files (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5521


    #### 4.2.2.3 Ensure journald is configured to write logfiles to
    ####         persistent disk (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5522

    ### 4.2.3 Ensure permissions on all logfiles are configured (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5523

    ## 4.3 Ensure logrotate is configured (Not Scored)

    # 5 Access, Authentication and Authorization

    ## 5.1 Configure cron

    ### 5.1.1 Ensure cron daemon is enabled (Scored)
    - service_crond_enabled


    ### 5.1.2 Ensure permissions on /etc/crontab are configured (Scored)
    # chown root:root /etc/crontab
    - file_owner_crontab
    - file_groupowner_crontab
    # chmod og-rwx /etc/crontab
    - file_permissions_crontab

    ### 5.1.3 Ensure permissions on /etc/cron.hourly are configured (Scored)
    # chown root:root /etc/cron.hourly
    - file_owner_cron_hourly
    - file_groupowner_cron_hourly
    # chmod og-rwx /etc/cron.hourly
    - file_permissions_cron_hourly

    ### 5.1.4 Ensure permissions on /etc/cron.daily are configured (Scored)
    # chown root:root /etc/cron.daily
    - file_owner_cron_daily
    - file_groupowner_cron_daily
    # chmod og-rwx /etc/cron.daily
    - file_permissions_cron_daily

    ### 5.1.5 Ensure permissions on /etc/cron.weekly are configured (Scored)
    # chown root:root /etc/cron.weekly
    - file_owner_cron_weekly
    - file_groupowner_cron_weekly
    # chmod og-rwx /etc/cron.weekly
    - file_permissions_cron_weekly

    ### 5.1.6 Ensure permissions on /etc/cron.monthly are configured (Scored)
    # chown root:root /etc/cron.monthly
    - file_owner_cron_monthly
    - file_groupowner_cron_monthly
    # chmod og-rwx /etc/cron.monthly
    - file_permissions_cron_monthly

    ### 5.1.7 Ensure permissions on /etc/cron.d are configured (Scored)
    # chown root:root /etc/cron.d
    - file_owner_cron_d
    - file_groupowner_cron_d
    # chmod og-rwx /etc/cron.d
    - file_permissions_cron_d

    ### 5.1.8 Ensure at/cron is restricted to authorized users (Scored)


    ## 5.2 SSH Server Configuration

    ### 5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured (Scored)
    # chown root:root /etc/ssh/sshd_config
    - file_owner_sshd_config
    - file_groupowner_sshd_config

    # chmod og-rwx /etc/ssh/sshd_config
    - file_permissions_sshd_config

    ### 5.2.2 Ensure SSH access is limited (Scored) 


    ### 5.2.3 Ensure permissions on SSH private host key files are
    ###       configured (Scored)
    # TO DO: The rule sets to 640, but benchmark wants 600
    - file_permissions_sshd_private_key
    # TO DO: check owner of private keys in /etc/ssh is root:root

    ### 5.2.4 Ensure permissions on SSH public host key files are configured
    ###      (Scored)
    - file_permissions_sshd_pub_key
    # TO DO: check owner of pub keys in /etc/ssh is root:root

    ### 5.2.5 Ensure SSH LogLevel is appropriate (Scored)
    - sshd_set_loglevel_info

    ### 5.2.6 Ensure SSH X11 forward is disabled (Scored)
    - sshd_disable_x11_forwarding

    ### 5.2.7 Ensure SSH MaxAuthTries is set to 4 or less (Scored)
    - sshd_max_auth_tries_value=4
    - sshd_set_max_auth_tries

    ### 5.2.8 Ensure SSH IgnoreRhosts is enabled (Scored)
    - sshd_disable_rhosts

    ### 5.2.9 Ensure SSH HostbasedAuthentication is disabled (Scored)
    - disable_host_auth

    ### 5.2.10 Ensure SSH root login is disabled (Scored)
    - sshd_disable_root_login

    ### 5.2.11 Ensure SSH PermitEmptyPasswords is disabled (Scored)
    - sshd_disable_empty_passwords

    ### 5.2.12 Ensure SSH PermitUserEnvironment is disabled (Scored)
    - sshd_do_not_permit_user_env

    ### 5.2.13 Ensure SSH Idle Timeout Interval is configured (Scored)
    # ClientAliveInterval 300
    - sshd_idle_timeout_value=5_minutes
    - sshd_set_idle_timeout

    # ClientAliveCountMax 0
    - var_sshd_set_keepalive=0
    - sshd_set_keepalive_0

    ### 5.2.14 Ensure SSH LoginGraceTime is set to one minute
    ###        or less (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5525

    ### 5.2.15 Ensure SSH warning banner is configured (Scored)
    - sshd_enable_warning_banner

    ### 5.2.16 Ensure SSH PAM is enabled (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5526

    ### 5.2.17 Ensure SSH AllowTcpForwarding is disabled (Scored)
    - sshd_disable_tcp_forwarding

    ### 5.2.18 Ensure SSH MaxStarups is configured (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5528

    ### 5.2.19 Ensure SSH MaxSessions is set to 4 or less (Scored)
    - sshd_set_max_sessions
    - var_sshd_max_sessions=4

    ### 5.2.20 Ensure system-wide crypto policy is not over-ridden (Scored)
    - configure_ssh_crypto_policy

    ## 5.3 Configure authselect


    ### 5.3.1 Create custom authselectet profile (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5530

    ### 5.3.2 Select authselect profile (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5531

    ### 5.3.3 Ensure authselect includes with-faillock (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5532

    ## 5.4 Configure PAM

    ### 5.4.1 Ensure password creation requirements are configured (Scored)
    # NEEDS RULE: try_first_pass - https://github.com/ComplianceAsCode/content/issues/5533
    - accounts_password_pam_retry
    - var_password_pam_minlen=14
    - accounts_password_pam_minlen
    - var_password_pam_minclass=4
    - accounts_password_pam_minclass

    ### 5.4.2 Ensure lockout for failed password attempts is
    ###       configured (Scored)
    - var_accounts_passwords_pam_faillock_unlock_time=900
    - var_accounts_passwords_pam_faillock_deny=5
    - accounts_passwords_pam_faillock_unlock_time
    - accounts_passwords_pam_faillock_deny

    ### 5.4.3 Ensure password reuse is limited (Scored)
    - var_password_pam_unix_remember=5
    - accounts_password_pam_unix_remember

    ### 5.4.4 Ensure password hashing algorithm is SHA-512 (Scored)
    - set_password_hashing_algorithm_systemauth

    ## 5.5 User Accounts and Environment

    ### 5.5.1 Set Shadow Password Suite Parameters

    #### 5.5.1 Ensure password expiration is 365 days or less (Scored)
    - var_accounts_maximum_age_login_defs=365
    - accounts_maximum_age_login_defs

    #### 5.5.1.2 Ensure minimum days between password changes is 7
    ####         or more (Scored)
    - var_accounts_minimum_age_login_defs=7
    - accounts_minimum_age_login_defs

    #### 5.5.1.3 Ensure password expiration warning days is
    ####         7 or more (Scored)
    - var_accounts_password_warn_age_login_defs=7
    - accounts_password_warn_age_login_defs

    #### 5.5.1.4 Ensure inactive password lock is 30 days or less (Scored)
    # TODO: Rule doesn't check list of users
    # https://github.com/ComplianceAsCode/content/issues/5536
    - var_account_disable_post_pw_expiration=30
    - account_disable_post_pw_expiration

    #### 5.5.1.5 Ensure all users last password change date is
    ####         in the past (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5537

    ### 5.5.2 Ensure system accounts are secured (Scored)
    - no_shelllogin_for_systemaccounts

    ### 5.5.3 Ensure default user shell timeout is 900 seconds
    ###       or less (Scored)
    - var_accounts_tmout=15_min
    - accounts_tmout

    ### 5.5.4 Ensure default group for the root account is
    ###       GID 0 (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5539

    ### 5.5.5 Ensure default user mask is 027 or more restrictive (Scored)
    - var_accounts_user_umask=027
    - accounts_umask_etc_bashrc
    - accounts_umask_etc_profile

    ## 5.6 Ensure root login is restricted to system console (Not Scored)
    - securetty_root_login_console_only
    - no_direct_root_logins

    ## 5.7 Ensure access to the su command is restricted (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5541

    # System Maintenance

    ## 6.1 System File Permissions

    ### 6.1.1 Audit system file permissions (Not Scored)
    - rpm_verify_permissions
    - rpm_verify_ownership
    
    ### 6.1.2 Ensure permissions on /etc/passwd are configured (Scored)
    # chown root:root /etc/passwd
    - file_owner_etc_passwd
    - file_groupowner_etc_passwd

    # chmod 644 /etc/passwd
    - file_permissions_etc_passwd

    ### 6.1.3 Ensure permissions on /etc/shadow are configured (Scored)
    # chown root:root /etc/shadow
    - file_owner_etc_shadow
    - file_groupowner_etc_shadow

    # chmod o-rwx,g-wx /etc/shadow
    - file_permissions_etc_shadow

    ### 6.1.4 Ensure permissions on /etc/group are configured (Scored)
    # chown root:root /etc/group
    - file_owner_etc_group
    - file_groupowner_etc_group

    # chmod 644 /etc/group
    - file_permissions_etc_group

    ### 6.1.5 Ensure permissions on /etc/gshadow are configured (Scored)
    # chown root:root /etc/gshadow
    - file_owner_etc_gshadow
    - file_groupowner_etc_gshadow

    # chmod o-rwx,g-rw /etc/gshadow
    - file_permissions_etc_gshadow

    ### 6.1.6 Ensure permissions on /etc/passwd- are configured (Scored)
    # chown root:root /etc/passwd-
    - file_owner_backup_etc_passwd
    - file_groupowner_backup_etc_passwd

    # chmod 644 /etc/passwd-
    - file_permissions_backup_etc_passwd

    ### 6.1.7 Ensure permissions on /etc/shadow- are configured (Scored)
    # chown root:root /etc/shadow-
    - file_owner_backup_etc_shadow
    - file_groupowner_backup_etc_shadow

    # chmod 0000 /etc/shadow-
    - file_permissions_backup_etc_shadow

    ### 6.1.8 Ensure permissions on /etc/group- are configured (Scored)
    # chown root:root /etc/group-
    - file_owner_backup_etc_group
    - file_groupowner_backup_etc_group

    # chmod 644 /etc/group-
    - file_permissions_backup_etc_group
    
    ### 6.1.9 Ensure permissions on /etc/gshadow- are configured (Scored)
    # chown root:root /etc/gshadow-
    - file_owner_backup_etc_gshadow
    - file_groupowner_backup_etc_gshadow

    # chmod 0000 /etc/gshadow-
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

    ### 6.2.2 Ensure no legacy "+" entries exist in /etc/passwd (Scored)
    - no_legacy_plus_entries_etc_passwd

    ### 6.2.4 Ensure no legacy "+" entries exist in /etc/shadow (Scored)
    - no_legacy_plus_entries_etc_shadow

    ### 6.2.5 Ensure no legacy "+" entries exist in /etc/group (Scored)
    - no_legacy_plus_entries_etc_group

    ### 6.2.6 Ensure root is the only UID 0 account (Scored)
    - accounts_no_uid_except_zero

    ### 6.2.7 Ensure users' home directories permissions are 750
    ###       or more restrictive (Scored)
    - file_permissions_home_dirs

    ### 6.2.8 Ensure users own their home directories (Scored)
    # NEEDS RULE for user owner @ https://github.com/ComplianceAsCode/content/issues/5507
    - file_groupownership_home_directories

    ### 6.2.9 Ensure users' dot files are not group or world
    ###       writable (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5506

    ### 6.2.10 Ensure no users have .forward files (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5505

    ### 6.2.11 Ensure no users have .netrc files (Scored)
    - no_netrc_files

    ### 6.2.12 Ensure users' .netrc Files are not group or
    ###        world accessible (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5504

    ### 6.2.13 Ensure no users have .rhosts files (Scored)
    - no_rsh_trust_files

    ### 6.2.14 Ensure all groups in /etc/passwd exist in
    ###        /etc/group (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5503

    ### 6.2.15 Ensure no duplicate UIDs exist (Scored)
    # NEEDS RULE -  https://github.com/ComplianceAsCode/content/issues/5502

    ### 6.2.16 Ensure no duplicate GIDs exist (Scored)
    # NEEDS RULE -  https://github.com/ComplianceAsCode/content/issues/5501

    ### 6.2.17 Ensure no duplicate user names exist (Scored)
    - account_unique_name

    ### 6.2.18 Ensure no duplicate group names exist (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5500

    ### 6.2.19 Ensure shadow group is empty (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5499

    ### 6.2.20 Ensure all users' home directories exist (Scored)
    - accounts_user_interactive_home_directory_exists
