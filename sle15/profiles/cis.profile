documentation_complete: true

title: 'CIS SUSE Linux Enterprise 15 Benchmark'

description: |-
    This baseline aligns to the Center for Internet Security
    SUSE Linux Enterprise 15 Benchmark, v1.0.0, currently in draft.

selections:

    ### Partitioning
    - mount_option_home_nodev

    ## 1.1 Filesystem Configuration

    ### 1.1.1 Disable unused filesystems

    #### 1.1.1.1 Ensure mounting cramfs filesystems is disabled (Scored)
    - kernel_module_cramfs_disabled

    #### 1.1.1.2 Ensure mounting of squashfs filesystems is disabled (Scored)
    - kernel_module_squashfs_disabled

    #### 1.1.1.3 Ensure mounting of udf filesystems is disabled (Scored)
    - kernel_module_udf_disabled

    #### 1.1.1.4 Ensure mounting of vFAT flesystems is limited (Not Scored)
    - kernel_module_vfat_disabled

    ### 1.1.2 Ensure /tmp is configured (Scored)
    - partition_for_tmp

    ### 1.1.3 Ensure noexec option set on /tmp partition (Scored)
    - mount_option_tmp_noexec

    ### 1.1.4 Ensure nodev option set on /tmp partition (Scored)
    - mount_option_tmp_nodev

    ### 1.1.5 Ensure nosuid option set on /tmp partition (Scored)
    - mount_option_tmp_nosuid

    ### 1.1.6 Ensure /dev/shm is configured (Scored)

    ### 1.1.7 Ensure noexec option set on /dev/shm (Scored)
    - mount_option_dev_shm_noexec

    ### 1.1.8 Ensure nodev option set on /dev/shm (Scored)
    - mount_option_dev_shm_nodev

    ### 1.1.9 Ensure nosuid option set on /dev/shm (Scored)
    - mount_option_dev_shm_nosuid

    ### 1.1.10 Ensure separate partition exists for /var (Scored)
    - partition_for_var

    ### 1.1.11 Ensure separate partition exists for /var/tmp (Scored)
    - partition_for_var_tmp

    ### 1.1.12 Ensure nodev option set on /var/tmp partition (Scored)
    - mount_option_var_tmp_nodev

    ### 1.1.13 Ensure nosuid option set on /var/tmp partition (Scored)
    - mount_option_var_tmp_nosuid

    ### 1.1.14 Ensure noexec option set on /var/tmp partition (Scored)
    - mount_option_var_tmp_noexec

    ### 1.1.15 Ensure separate partition exists for /var/log (Scored)
    - partition_for_var_log

    ### 1.1.16 Ensure separate partition exists for /var/log/audit (Scored)
    - partition_for_var_log_audit

    ### 1.1.17 Ensure separate partition exists for /home (Scored)
    - partition_for_home

    ### 1.1.18 Ensure nodev option set on /home partition (Scored)
    - mount_option_home_nodev

    ### 1.1.19 Ensure nodev option set on removable media partitions (Not Scored)
    - mount_option_nodev_removable_partitions

    ### 1.1.20 Ensure nosuid option set on removable media partitions (Not Scored)
    - mount_option_nosuid_removable_partitions

    ### 1.1.21 Ensure noexec option set on removable media partitions (Not Scored)
    - mount_option_noexec_removable_partitions

    ### 1.1.22 Ensure sticky bit is set on all world-writable directories (Scored)
    - dir_perms_world_writable_sticky_bits

    ### 1.1.23 Disable Automounting (Scored)
    - service_autofs_disabled

    ### 1.1.24 Disable USB Storage (Scored)
    - kernel_module_usb-storage_disabled

    ## 1.2 Configure Software Updates

    ### 1.2.1 Ensure GPG keys are configured (Not Scored)
    # NEEDS RULE FOR SUSE

    ### 1.2.2 Ensure package manager repositories are configured (Scored)
    # NEEDS RULE -
   
    ### 1.2.3 Ensure gpgcheck is globally activated (Scored)
    - ensure_gpgcheck_globally_activated  

    ## 1.3 Configure sudo

    ### 1.3.1 Ensure sudo is installed (Scored)
    - package_sudo_installed

    ### 1.3.2 Ensure sudo commands use pty (Scored)
    # NEEDS RULE -

    ### 1.3.3 Ensure sudo log file exists (Scored)
    # NEEDS RULE -

    ## 1.4 Filesystem Integrity Checking

    ### 1.4.1 Ensure AIDE is installed (Scored)
    - package_aide_installed

    ### 1.4.2 Ensure filesystem integrity is regularly checked (Scored)
    - aide_periodic_cron_checking

    ## 1.5 Secure Boot Settings

    ### 1.5.1 Ensure bootloader password is set (Scored)
    - grub2_password
    
    ### 1.5.2 Ensure permissions on bootloader config are configured (Scored)
    #### chown root:root /boot/grub2/grub.cfg
    - file_owner_grub2_cfg
    - file_groupowner_grub2_cfg

    #### chmod og-rwx /boot/grub2/grub.cfg
    - file_permissions_grub2_cfg

    #### chown root:root /boot/grub2/grubenv
    # NEED RULE -

    #### chmod og-rwx /boot/grub2/grubenv
    # NEED RULE -

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

    ### 1.6.2 Ensure XD/NS support is enabled (Scored)
    #### No configuration required for 64-bit systems

    ### 1.6.3 Ensure address space layout randomization (ASLR) is enabled
    - sysctl_kernel_randomize_va_space

    ## 1.7 Mandatory Access Control

    ### 1.7.1 Ensure Mandatory Access Control Software is Installed

    #### 1.7.1.1 Ensure AppArmor is installed (Scored)
    #### Need Rule

    #### 1.7.1.2 Ensure AppArmor is not disabled in bootloader configuration (Scored)
    #### Need Rule

    #### 1.7.1.3 Ensure all AppArmor Profiles are in enforce or complain (Scored)
    #### Need Rule

    #### 1.7.1.4 Ensure all AppArmor Profiles are enforcing (Scored)
    #### Need Rule

    ## 1.8 Warning Banners

    ### 1.8.1 Command Line Warning Baners

    #### 1.8.1.1 Ensure message of the day is configured properly (Scored)
    - banner_etc_motd

    #### 1.8.1.2 Ensure local login warning banner is configured properly (Scored)
    - banner_etc_issue

    #### 1.8.1.3 Ensure remote login warning banner is configured properly (Scored)
    # NEEDS RULE

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

    ## 1.9 Ensure updates, patches, and additional security software are installed (Unscored)
    - security_patches_up_to_date

    ## 1.10 Ensure GDM is removed or login is configured (Scored)
    ## Need Rule

    # 2 Services

    ## 2.1 inetd Services

    ### 2.1.1 Ensure xinetd is not enabled (Scored)
    - service_xinetd_disabled 

    ## 2.2 Special Purpose Services
    ### 2.2.1 Time Synchronization
    #### 2.2.1.1 Ensure time synchronization is in use (Unscored)
    - package_chrony_installed

    #### 2.2.1.2 Ensure chrony is configured (Scored)
    - service_chronyd_enabled
    - chronyd_specify_remote_server
    - chronyd_run_as_chrony_user

    #### 2.2.1.3 Ensure ntp is configured (Scored)
    # This requirement is not applicable
    # This profile opts to use chrony rather than ntp

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

    ### 2.2.8 Ensure rpcbind is not enabled (Scored)
    - service_rpcbind_disabled

    ### 2.2.9 Ensure DNS Server is not enabled (Scored)
    - service_named_disabled

    ### 2.2.10 Ensure FTP Server is not enabled (Scored)
    - service_vsftpd_disabled

    ### 2.2.11 Ensure HTTP server is not enabled (Scored)
    - service_httpd_disabled

    ### 2.2.12 Ensure IMAP and POP3 server is not enabled (Scored)
    - service_dovecot_disabled

    ### 2.2.13 Ensure Samba is not enabled (Scored)
    - service_smb_disabled

    ### 2.2.14 Ensure HTTP Proxy Server is not enabled (Scored)
    - service_squid_disabled

    ### 2.2.15 Ensure SNMP Server is not enabled (Scored)
    - service_snmpd_disabled

    ### 2.2.16 Ensure mail transfer agent is configured for local-only mode (Scored)
    - postfix_network_listening_disabled

    ### 2.2.17 Ensure rsync service is not enabled (Scored)
    - service_rsyncd_disabled

    ### 2.2.18 Ensure NIS Server is not enabled (Scored)
    - package_ypserv_removed

    ### 2.2.19 Ensure telnet-server is not installed (Scored)
    - package_telnetd_removed

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
    ## 3.1 Disable unused network protocols
    ### 3.1.1 Disable IPv6
    - grub2_ipv6_disable_argument

    ### 3.1.2 Ensure wireless interfaces are disabled
    - wireless_disable_interfaces

    ## 3.2 Network Parameters (Host Only)
    ### 3.2.1 Ensure IP forwarding is disabled (Scored)
    - sysctl_net_ipv4_ip_forward

    ### 3.2.2 Ensure packet redirect sending is disabled (Scored)
    - sysctl_net_ipv4_conf_all_send_redirects
    - sysctl_net_ipv4_conf_default_send_redirects

    ## 3.3 Network Parameters (Host and Router)
    ### 3.3.1 Ensure source routed packets are not accepted (Scored)
    - sysctl_net_ipv4_conf_all_accept_source_route
    - sysctl_net_ipv4_conf_default_accept_source_route

    ### 3.3.2 Ensure ICMP redirects are not accepted (Scored)
    - sysctl_net_ipv4_conf_all_accept_redirects
    - sysctl_net_ipv4_conf_default_accept_redirects

    ### 3.3.3 Ensure secure ICMP redirects are not accepted (Scored)
    - sysctl_net_ipv4_conf_all_secure_redirects
    - sysctl_net_ipv4_conf_default_secure_redirects

    ### 3.3.4 Ensure suspicious packets are logged (Scored)
    - sysctl_net_ipv4_conf_all_log_martians
    - sysctl_net_ipv4_conf_default_log_martians

    ### 3.3.5 Ensure broadcast ICMP requests are ignored (Scored)
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts

    ### 3.3.6 Ensure bogus ICMP responses are ignored (Scored)
    - sysctl_net_ipv4_icmp_ignore_bogus_error_responses

    ### 3.3.7 Ensure Reverse Path Filtering is enabled (Scored)
    - sysctl_net_ipv4_conf_all_rp_filter
    - sysctl_net_ipv4_conf_default_rp_filter

    ### 3.3.8 Ensure TCP SYN Cookies is enabled (Scored)
    - sysctl_net_ipv4_tcp_syncookies

    ### 3.3.9 Ensure IPv6 router advertisements are not accepted (Not Scored)
    - sysctl_net_ipv6_conf_all_accept_ra
    - sysctl_net_ipv6_conf_default_accept_ra

    ## 3.4 Uncommon Network Protocols
    ### 3.4.1 Ensure DCCP is disabled (Not Scored)
    - kernel_module_dccp_disabled

    ### 3.4.2 Ensure SCTP is disabled (Not Scored)
    - kernel_module_sctp_disabled

    ## 3.5 Firewall Configuration
    ### 3.5.1 Configure FirewallD
    #### 3.5.1.1 Ensure FirewallD is installed (Scored)
    ##- package_firewalld_installed
    - package_iptables_installed
    
    #### 3.5.1.2 Ensure iptables-services package is not installed (Scored)
    #### NEED RULE

    #### 3.5.1.3 Ensure nftables is not installed (Scored)
    #### Need rule

    #### 3.5.1.4 Ensure firewalld service is enabled (Scored)
    - service_firewalld_enabled

    #### 3.5.1.5 Ensure default zone is set (Scored)
    - set_firewalld_default_zone

    #### 3.5.1.6 Ensure network interfaces are assigned to appropriate zone (Unscored)
    #### Need rule

    #### 3.5.1.7 Ensure unnecessary services and ports are not accepted (Unscored)
    #### NEED RULE

    ### 3.5.2 Configure nftables
    #### 3.5.2.1 Ensure nftables is installed (Scored)
    #### 3.5.2.2 Ensure firewalld is not installed (Scored)
    #### 3.5.2.3 Ensure iptables-services package is not installed (Scored)
    #### 3.5.2.4 Ensure iptables are flushed (Unscored)
    #### 3.5.2.5 Ensure a table exists (Scored)
    #### 3.5.2.6 Ensure a base chain exists (Scored)
    #### 3.5.2.7 Ensure loopback traffic is configured (Scored)
    #### 3.5.2.8 Ensure outbound and established connections are configured (Scored)
    #### 3.5.2.9 Ensure default deny firewall policy
    #### 3.5.2.10 Ensure nftables is enabled (Scored)
    #### 3.5.2.11 Ensure nftables rules are permanent
 
    ### 3.5.3 Configure iptables
    #### 3.5.3.1 Configure software
    ##### 3.5.3.1.1 Ensure iptables is installed (Scored)
    - package_iptables_installed
    ##### 3.5.3.1.2 Ensure nftables is not installed (Scored)
    ##### 3.5.3.1.3 Ensure firewalld is not installed (Scored)

    #### 3.5.3.2 Configure IPv4 iptables
    ##### 3.5.3.2.1 Ensure default deny firewall policy (Scored)
    - set_iptables_default_rule
    ##### 3.5.3.2.2 Ensure loopback traffic is configured (Scored)
    ##### 3.5.3.2.3 Ensure outbound and established connections are configured (Scored)
    ##### 3.5.3.2.4 Ensure firewall rules exist for all open ports (Scored)
    ##### 3.5.3.2.5 Ensure iptables rules are saved (Scored)
    ##### 3.5.3.2.6 Ensure iptables is enabled and running (Scored)
    - service_iptables_enabled 

    #### 3.5.3.3 Configure IPv6 iptables
    ##### 3.5.3.3.1 Ensure IPv6 default deny firewall policy (Scored)
    - set_ip6tables_default_rule
    ##### 3.5.3.3.2 Ensure IPv6 loopback traffic is configured (Scored)
    ##### 3.5.3.3.3 Ensure IPv6 outbound and established connections are configured (Scored)
    ##### 3.5.3.3.4 Ensure IPv6 firewall rules exist for all open ports (Scored)
    ##### 3.5.3.3.5 Ensure ip6tables rules are saved (Score)
    ##### 3.5.3.3.6 Ensure ip6tables is enabled and running (Scored)
    - service_ip6tables_enabled

    # 4 Logging and Auditing

    ## 4.1 Configure System Accounting (auditd)
    ### 4.1.1 Ensure Auditing is enabled
    ###  4.1.1.1 Ensure auditd is installed (Scored)
    - package_audit_installed

    #### 4.1.1.2 Ensure auditd service is enabled (Scored)
    - service_auditd_enabled

    #### 4.1.1.3 Ensure auditing for processes that start prior to audit
    ####         is enabled (Scored)
    - grub2_audit_argument

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

   #### 4.1.2.4 Ensure audit_backlog_limit is sufficient (Scored)
    - grub2_audit_backlog_limit_argument

    ### 4.1.3 Ensure events that modify date and time information
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

    ### 4.1.4 Ensure events that modify user/group information are
    ###        collected (Scored)

    ### 4.1.5 Ensure events that modify the system's network
    ###       enironment are collected (Scored)
    - audit_rules_networkconfig_modification

    ### 4.1.6 Ensure events that modify the system's Mandatory
    ###       Access Control are collected (Scored)
    #### -w /etc/selinux/ -p wa
    - audit_rules_mac_modification

    #### -w /usr/share/selinux/ -p wa
    # NEED RULE - https://github.com/ComplianceAsCode/content/issues/5264

    ### 4.1.7 Ensure login and logout events are collected (Scored)
    - audit_rules_login_events_faillock
    - audit_rules_login_events_lastlog

    ### 4.1.8 Ensure session initiation information is collected (Scored)
    - audit_rules_session_events

    ### 4.1.9 Ensure discretionary access control permission modification
    ###       events are collected (Scored)

    ### 4.1.10 Ensure unsuccessful unauthorized file access attempts are
    ###        collected (Scored)

    ### 4.1.11 Ensure use of privileged commands is collected (Scored)

    ### 4.1.12 Ensure successful file system mounts are collected (Scored)

    ### 4.1.13 Ensure file deletion events by users are collected
    ###        (Scored)

    ### 4.1.14 Ensure changes to system administration scope
    ###       (sudoers) is collected (Scored)
    - audit_rules_sysadmin_actions

    ### 4.1.15 Ensure system administrator actions (sudolog) are
    ###        collected (Scored)

    ### 4.1.16 Ensure kernel module loading and unloading is collected
    ###        (Scored)

    ### 4.1.17 Ensure the audit configuration is immutable (Scored)

    ## 4.2 Configure Logging

    ### 4.2.1 Configure rsyslog

    #### 4.2.1.1 Ensure rsyslog is installed (Scored)
    - package_rsyslog_installed

    #### 4.2.1.2 Ensure rsyslog Service is enabled (Scored)
    - service_rsyslog_enabled

    #### 4.2.1.3 Ensure rsyslog default file permissions configured (Scored)
    - rsyslog_files_groupownership
    - rsyslog_files_ownership
    - rsyslog_files_permissions

    #### 4.2.1.4 Ensure logging is configured (Not Scored)

    #### 4.2.1.5 Ensure rsyslog is configured to send logs to a remote
    ####         log host (Scored)
    - rsyslog_remote_loghost

    #### 4.2.1.6 Ensure remote rsyslog messages are only accepted on
    ####         designated log hosts (Not Scored) 

    ### 4.2.2 Configure journald

    #### 4.2.2.1 Ensure journald is configured to send logs to
    ####         rsyslog (Scored)

    #### 4.2.2.2 Ensure journald is configured to compress large
    ####         log files (Scored)

    #### 4.2.2.3 Ensure journald is configured to write logfiles to
    ####         persistent disk (Scored)

    ### 4.2.3 Ensure permissions on all logfiles are configured (Scored)

    ### 4.2.4 Ensure logrotate is conifgured (Not Scored)
    - ensure_logrotate_activated

    # 5 Access, Authentication and Authorization

    ## 5.1 Configure time-based job schedulers

    ### 5.1.1 Ensure cron daemon is enabled (Scored)

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

    ### 5.1.9 Ensure at is restricted to authorized users (Scored)

    ## 5.2 SSH Server Configuration

    ### 5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured (Scored)
    # chown root:root /etc/ssh/sshd_config
    - file_owner_sshd_config
    - file_groupowner_sshd_config

    # chmod og-rwx /etc/ssh/sshd_config
    - file_permissions_sshd_config

    ### 5.2.2 Ensure permissions on SSH private host key files are
    ###       configured (Scored)
    # TO DO: The rule sets to 640, but benchmark wants 600
    - file_permissions_sshd_private_key
    # TO DO: check owner of private keys in /etc/ssh is root:root

    ### 5.2.3 Ensure permissions on SSH public host key files are configured
    ###      (Scored)
    - file_permissions_sshd_pub_key
    # TO DO: check owner of pub keys in /etc/ssh is root:root

    ### 5.2.4 Ensure SSH access is limited (Scored)

    ### 5.2.5 Ensure SSH LogLevel is appropriate (Scored)
    - sshd_set_loglevel_info

    ### 5.2.6 Ensure SSH X11 forward is diabled (Scored)
    # - sshd_disable_x11_forwarding waiting until my pull request is merged

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

    ### 5.2.13 Ensure only strong Ciphers are used (Scored)
    - sshd_use_strong_ciphers

    ### 5.2.14 Ensure only strong MAC algorithms are used (Scored)
    - sshd_use_strong_macs

    ### 5.2.15 Ensure only strong Key Exchange algorithms are used (Scored)

    ### 5.2.16 Ensure SSH Idle Timeout Interval is configured (Scored)
    # ClientAliveInterval 300
    - sshd_idle_timeout_value=5_minutes
    - sshd_set_idle_timeout

    # ClientAliveCountMax 0
    - sshd_set_keepalive

    ### 5.2.17 Ensure SSH LoginGraceTime is set to one minute
    ###        or less (Scored)    

    ### 5.2.18 Ensure SSH warning banner is configured (Scored)
    - sshd_enable_warning_banner

    ### 5.2.19 Ensure SSH PAM is enabled (Scored)

    ### 5.2.20 Ensure SSH AllowTcpForwarding is disabled (Scored)
    - sshd_disable_tcp_forwarding
    
    ### 5.2.21 Ensure SSH MaxStartups is configured (Scored)

    ### 5.2.22 Ensure SSH MaxSessions is set to 4 or less (Scored)

    ## 5.3 Configure PAM

    ### 5.3.1 Ensure password creation requirements are configured (Scored)

    ### 5.3.2 Ensure lockout for failed password attempts is
    ###       configured (Scored)

    ### 5.3.4 Ensure password hashing algorithm is SHA-512 (Scored)

    ### 5.3.3 Ensure password reuse is limited (Scored)

    ## 5.4 User Accounts and Environment

    ### 5.4.1 Set Shadow Password Suite Parameters

    #### 5.4.1.1 Ensure password expiration is 365 days or less (Scored)

    #### 5.4.1.2 Ensure minimum days between password changes is 7
    ####         or more (Scored)

    #### 5.4.1.3 Ensure password expiration warning days is
    ####         7 or more (Scored)

    #### 5.4.1.4 Ensure inactive password lock is 30 days or less (Scored)

    #### 5.4.1.5 Ensure all users last password change date is
    ####         in the past (Scored)

    ### 5.4.2 Ensure system accounts are secured (Scored)

    ### 5.4.3 Ensure default group for the root account is
    ###       GID 0 (Scored)

    ### 5.4.4 Ensure default user shell timeout is 900 seconds
    ###       or less (Scored)

    ### 5.4.5 Ensure default user mask is 027 or more restrictive (Scored)

    ## 5.5 Ensure root login is restricted to system console (Not Scored)

    ## 5.6 Ensure access to the su command is restricted (Scored)

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

    # chmod 600 /etc/passwd-
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

    ### 6.2.1 Ensure accounts in /etc/passwd use shadowed passwords (Scored)

    ### 6.2.2 Ensure /etc/shadow password fields are not empty (Scored)

    ### 6.2.3 Ensure root is the only UID 0 account (Scored)

    ### 6.2.4 Ensure root PATH Integrity (Scored)

    ### 6.2.5 Ensure all users' home directories exist (Scored) 

    ### 6.2.6 Ensure users' home directories permissions are 750 or more
    ### restrictive (Scored)

    ### 6.2.7 Ensure users own their home directories (Scored)

    ### 6.2.8 Ensure users' dot files are not group or world writable (Scored)

    ### 6.2.9 Ensure no users have .forward files (Scored)

    ### 6.2.10 Ensure no users have .netrc files (Scored)

    ### 6.2.11 Ensure users' .netrc Files are not group or world accessible (Scored)

    ### 6.2.12 Ensure no users have .rhosts files (Scored)

    ### 6.2.13 Ensure all groups in /etc/passwd exist in /etc/group (Scored)

    ### 6.2.14 Ensure no duplicate UIDs exist (Scored)

    ### 6.2.15 Ensure no duplicate GIDs exist (Scored)

    ### 6.2.16 Ensure no duplicate user names exist (Scored)

    ### 6.2.17 Ensure no duplicate group names exist (Scored)

    ### 6.2.18 Ensure shadow group is empty (Scored)
