documentation_complete: true

title: 'CIS Ubuntu 20.04 Level 1 Server Benchmark'

description: |-
    This baseline aligns to the Center for Internet Security
    Ubuntu 20.04 LTS Benchmark, v1.0.0, released 07-21-2020.

selections:
    # 1 Initial Setup #
    ## 1.1 Filesystem Configuration ##
    ### 1.1.1 Disable unused filesystems ###
    #### 1.1.1.1 Ensure mounting of cramfs filesystems is disabled (Automated)
    - kernel_module_cramfs_disabled

    #### 1.1.1.2 Ensure mounting of freevxfs filesystems is disabled (Automated)
    - kernel_module_freevxfs_disabled

    #### 1.1.1.3 Ensure mounting of jffs2 filesystems is disabled (Automated)
    - kernel_module_jffs2_disabled

    #### 1.1.1.4 Ensure mounting of hfs filesystems is disabled (Automated)
    - kernel_module_hfs_disabled

    #### 1.1.1.5 Ensure mounting of hfsplus filesystems is disabled (Automated)
    - kernel_module_hfsplus_disabled

    #### 1.1.1.6 Ensure mounting of udf filesystems is disabled (Automated)
    - kernel_module_udf_disabled

    #### 1.1.1.7 Ensure mounting of FAT filesystems is limited (Manual)
    # Skip due to being Level 2

    ### 1.1.2 Ensure /tmp is configured (Automated)
    - partition_for_tmp

    ### 1.1.3 Ensure nodev option set on /tmp partition (Automated)
    # Needs rule

    ### 1.1.4 Ensure nosuid option set on /tmp partition (Automated)
    # Needs rule

    ### 1.1.5 Ensure noexec option set on /tmp partition (Automated)
    # Needs rule

    ### 1.1.6 Ensure /dev/shm is configured (Automated)
    # Skip due to being handled by systemd and ensured by follow-on tests

    ### 1.1.7 Ensure nodev option set on /dev/shm partition (Automated)
    - mount_option_dev_shm_nodev

    ### 1.1.8 Ensure nosuid option set on /dev/shm partition (Automated)
    - mount_option_dev_shm_nosuid

    ### 1.1.9 Ensure noexec option set on /dev/shm partition (Automated)
    - mount_option_dev_shm_noexec

    ### 1.1.10 Ensure separate partition exists for /var (Automated)
    # Skip due to being Level 2

    ### 1.1.11 Ensure separate partition exists for /var/tmp (Automated)
    # This is a Level 2 test but is needed for 1.1.12-14
    # partition_for_var_tmp

    ### 1.1.12 Ensure nodev option set on /var/tmp partition (Automated)
    # Needs rule

    ### 1.1.13 Ensure nosuid option set on /var/tmp partition (Automated)
    # Needs rule

    ### 1.1.14 Ensure noexec option set on /var/tmp partition (Automated)
    # Needs rule

    ### 1.1.15 Ensure separate partition exists for /var/log (Automated)
    # Skip due to being Level 2

    ### 1.1.16 Ensure separate partition exists for /var/log/audit (Automated)
    # Skip due to being Level 2

    ### 1.1.17 Ensure separate partition exists for /home (Automated)
    # This is a Level 2 test but is needed for 1.1.18
    # partition_for_home

    ### 1.1.18 Ensure nodev option set on /home partition (Automated)
    # Needs rule

    ### 1.1.19 Ensure nodev option set on removable media partitions (Manual)
    # Skip due to being a manual test

    ### 1.1.20 Ensure nosuid option set on removable media partitions (Manual)
    # Skip due to being a manual test

    ### 1.1.21 Ensure noexec option set on removable media partitions (Manual)
    # Skip due to being a manual test

    ### 1.1.22 Ensure sticky bit is set on all world-writable directories (Automated)
    - dir_perms_world_writable_sticky_bits

    ### 1.1.23 Disable Automounting (Automated)
    - service_autofs_disabled

    ### 1.1.24 Disable USB Storage (Automated)
    - kernel_module_usb-storage_disabled

    ## 1.2 Configure Software Updates ##
    ### 1.2.1 Ensure package manager repositories are configured (Manual)
    # Skip due to being a manual test

    ### 1.2.2 Ensure GPG keys are configured (Manual)
    # Skip due to being a manual test

    ## 1.3 Configure sudo ##
    ### 1.3.1 Ensure sudo is installed (Automated)
    - package_sudo_installed

    ### 1.3.2 Ensure sudo commands use pty (Automated)
    - sudo_add_use_pty

    ### 1.3.3 Ensure sudo log file exists (Automated)
    - sudo_custom_logfile

    ## 1.4 Filesystem Integrity Checking ##
    ### 1.4.1 Ensure AIDE is installed (Automated)
    - package_aide_installed
    - aide_build_database

    ### 1.4.2 Ensure filesystem integrity is regularly checked (Automated)
    - aide_periodic_cron_checking

    ## 1.5 Secure Boot Settings ##
    ### 1.5.1 Ensure bootloader password is set (Automated)
    - grub2_password
    - grub2_uefi_password

    ### 1.5.2 Ensure permissions on bootloader config are configured (Automated)
    - file_owner_grub2_cfg
    - file_permissions_grub2_cfg

    ### 1.5.3 Ensure authentication required for single user mode (Automated)
    # Needs variable
    # Needs rule

    ## 1.6 Additional Process Hardening ##
    ### 1.6.1 Ensure XD/NX support is enabled (Automated)
    # Needs rule

    ### 1.6.2 Ensure address space layout randomization (ASLR) is enabled (Automated)
    - sysctl_kernel_randomize_va_space

    ### 1.6.3 Ensure prelink is disabled (Automated)
    - package_prelink_removed

    ### 1.6.4 Ensure core dumps are restricted (Automated)
    - disable_users_coredumps
    - sysctl_fs_suid_dumpable

    ## 1.7 Mandatory Access Control ##
    ### 1.7.1 Configure AppArmor ###
    #### 1.7.1.1 Ensure AppArmor is installed (Automated)
    # Needs rule

    #### 1.7.1.2 Ensure AppArmor is enabled in the bootloader configuration (Automated)
    - grub2_enable_apparmor

    #### 1.7.1.3 Ensure all AppArmor Profiles are in enforce or complain mode (Automated)
    # Needs variable
    # Needs rule

    #### 1.7.1.4 Ensure all AppArmor Profiles are enforcing (Automated)
    # Skip due to being Level 2

    ## 1.8 Warning Banners ##
    ### 1.8.1 Command Line Warning Banners ###
    #### 1.8.1.1 Ensure message of the day is configured properly (Automated)
    # Needs rule

    #### 1.8.1.2 Ensure local login warning banner is configured properly (Automated)
    # Needs rule

    #### 1.8.1.3 Ensure remote login warning banner is configured properly (Automated)
    # Needs rule

    #### 1.8.1.4 Ensure permissions on /etc/motd are configured (Automated)
    - file_permissions_etc_motd
    - file_owner_etc_motd
    - file_groupowner_etc_motd

    #### 1.8.1.5 Ensure permissions on /etc/issue are configured (Automated)
    - file_permissions_etc_issue
    - file_owner_etc_issue
    - file_groupowner_etc_issue

    #### 1.8.1.6 Ensure permissions on /etc/issue.net are configured (Automated)
    # Needs rules

    ## 1.9 Ensure updates, patches, and additional security software are installed (Manual)
    # Manual rule; security_patches_up_to_date

    ## 1.10 Ensure GDM is removed or login is configured (Automated)
    - package_gdm_removed
    - '!enable_dconf_user_profile'
    - '!dconf_gnome_banner_enabled'
    - '!dconf_gnome_login_banner_text'
    - '!dconf_gnome_disable_user_list'

    # Services #
    ## 2.1 inetd Services ##
    ### 2.1.1 Ensure xinetd is not installed (Automated)
    - package_xinetd_removed

    ### 2.1.2 Ensure openbsd-inetd is not installed (Automated)
    # Needs rule

    ## 2.2 Special Purpose Services ##
    ### 2.2.1 Time Synchronization ###
    #### 2.2.1.1 Ensure time synchronization is in use (Automated)
    # Needs variable: var_time_synchronization_daemon=chrony
    - package_chrony_installed
    # Needs rule: package_ntp_removed
    - service_chronyd_or_ntpd_enabled

    #### 2.2.1.2 Ensure systemd-timesyncd is configured (Manual)
    # Needs rule: package_chrony_removed
    # Needs rule: package_ntp_removed
    # '!package_timesyncd_installed'
    # '!service_timesyncd_enabled'

    #### 2.2.1.3 Ensure chrony is configured (Automated)
    - chronyd_run_as_chrony_user
    - chronyd_specify_remote_server

    #### 2.2.1.4 Ensure ntp is configured (Automated)
    - package_ntp_installed
    # Needs rule: package_chrony_removed
    - service_ntp_enabled

    ### 2.2.2 Ensure X Window System is not installed (Automated)
    - package_xorg-x11-server-common_removed

    ### 2.2.3 Ensure Avahi Server is not installed (Automated)
    - service_avahi-daemon_disabled
    # Needs rule: package_avahi-daemon_removed

    ### 2.2.4 Ensure CUPS is not installed (Automated)
    - service_cups_disabled
    - package_cups_removed

    ### 2.2.5 Ensure DHCP Server is not installed (Automated)
    - package_dhcp_removed

    ### 2.2.6 Ensure LDAP server is not installed (Automated)
    - package_openldap-servers_removed

    ### 2.2.7 Ensure NFS is not installed (Automated)
    # Needs rule: package_nfs-kernel-server_removed

    ### 2.2.8 Ensure DNS Server is not installed (Automated)
    - package_bind_removed

    ### 2.2.9 Ensure FTP Server is not installed (Automated)
    - package_vsftpd_removed

    ### 2.2.10 Ensure HTTP server is not installed (Automated)
    - package_httpd_removed

    ### 2.2.11 Ensure IMAP and POP3 server are not installed (Automated)
    - package_dovecot_removed

    ### 2.2.12 Ensure Samba is not installed (Automated)
    - package_samba_removed

    ### 2.2.13 Ensure HTTP Proxy Server is not installed (Automated)
    - package_squid_removed

    ### 2.2.14 Ensure SNMP Server is not installed (Automated)
    - package_net-snmp_removed

    ### 2.2.15 Ensure mail transfer agent is configured for local-only mode (Automated)
    # Needs rule

    ### 2.2.16 Ensure rsync service is not installed (Automated)
    - package_rsync_removed

    ### 2.2.17 Ensure NIS Server is not installed (Automated)
    - package_nis_removed

    ## 2.3 Service Clients ##
    ### 2.3.1 Ensure NIS Client is not installed (Automated)
    # - package_nis_removed # (Duplicate of above)

    ### 2.3.2 Ensure rsh client is not installed (Automated)
    - package_rsh_removed

    ### 2.3.3 Ensure talk client is not installed (Automated)
    - package_talk_removed

    ### 2.3.4 Ensure telnet client is not installed (Automated)
    - package_telnet_removed

    ### 2.3.5 Ensure LDAP client is not installed (Automated)
    - package_openldap-clients_removed

    ### 2.3.6 Ensure RPC is not installed (Automated)
    - package_rpcbind_removed

    ## 2.4 Ensure nonessential services are removed or masked (Manual)
    # Skip due to being a manual test

    # 3 Network Configuration #
    ## 3.1 Disable unused network procols and devices ##
    ### 3.1.1 Disable IPv6 (Manual)
    # Skip due to being Level 2

    ### 3.1.2 Ensure wireless interfaces are disabled (Automated)
    - wireless_disable_interfaces

    ## 3.2 Network Parameters (Host Only) ##
    ### 3.2.1 Ensure packet redirect sending is disabled (Automated)
    - sysctl_net_ipv4_conf_all_send_redirects
    - sysctl_net_ipv4_conf_default_send_redirects

    ### 3.2.2 Ensure IP forwarding is disabled (Automated)
    - sysctl_net_ipv4_ip_forward
    - sysctl_net_ipv6_conf_all_forwarding

    ## 3.3 Network Parameters (Host and Router)
    ### 3.3.1 Ensure source routed packets are not accepted (Automated)
    - sysctl_net_ipv4_conf_all_accept_source_route
    - sysctl_net_ipv4_conf_default_accept_source_route
    - sysctl_net_ipv6_conf_all_accept_source_route
    - sysctl_net_ipv6_conf_default_accept_source_route

    ### 3.3.2 Ensure ICMP redirects are not accepted (Automated)
    - sysctl_net_ipv4_conf_all_accept_redirects
    - sysctl_net_ipv4_conf_default_accept_redirects
    - sysctl_net_ipv6_conf_all_accept_redirects
    - sysctl_net_ipv6_conf_default_accept_redirects

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

    ### 3.3.9 Ensure IPv6 router advertisements are not accepted (Automated)
    - sysctl_net_ipv6_conf_all_accept_ra
    - sysctl_net_ipv6_conf_default_accept_ra

    ## 3.4 Uncommon Network Protocols ##
    ### 3.4.1 Ensure DCCP is disabled (Automated)
    # Skip due to being Level 2

    ### 3.4.2 Ensure SCTP is disabled (Automated)
    # Skip due to being Level 2

    ### 3.4.3 Ensure RDS is disabled (Automated)
    # Skip due to being Level 2

    ### 3.4.4 Ensure TIPC is disabled (Automated)
    # Skip due to being Level 2

    ## 3.5 Firewall Configuration
    ### 3.5.1 Configure Uncomplicated Firewall
    #### 3.5.1.1 Ensure Uncomplicated Firewall is installed (Automated)
    # Needs rule

    #### 3.5.1.2 Ensure iptables-persistent is not installed (Automated)
    # Needs rule

    #### 3.5.1.3 Ensure ufw service is enabled (Automated)
    # Needs rule

    #### 3.5.1.4 Ensure loopback traffic is configured (Automated)
    # Needs rule

    #### 3.5.1.5 Ensure outbound connections are configured (Manual)
    # Skip due to being a manual test

    #### 3.5.1.6 Ensure firewall rules exist for all open ports (Manual)
    # Skip due to being a manual test

    #### 3.5.1.7 Ensure default deny firewall policy (Automated)
    # Needs rule

    ### 3.5.2 Configure nftables
    #### 3.5.2.1 Ensure nftables is installed (Automated)
    - package_nftables_installed

    #### 3.5.2.2 Ensure Uncomplicated Firewall is not installed or disabled (Automated)
    # Needs rule

    #### 3.5.2.3 Ensure iptables are flushed (Manual)
    # Skip due to being a manual test

    #### 3.5.2.4 Ensure a table exists (Automated)
    # Needs rule

    #### 3.5.2.5 Ensure base chains exist (Automated)
    # Needs rule

    #### 3.5.2.6 Ensure loopback traffic is configured (Automated)
    # Needs rule

    #### 3.5.2.7 Ensure outbound and established connections are configured (Manual)
    # Skip due to being a manual test

    #### 3.5.2.8 Ensure default deny firewall policy (Automated)
    # Needs rule

    #### 3.5.2.9 Ensure nftables service is enabled (Automated)
    # Needs rule

    #### 3.5.2.10 Ensure nftables rules are permanent (Automated)
    # Needs rule

    ### 3.5.3 Configure iptables ###
    #### 3.5.3.1 Configure software ####
    ##### 3.5.3.1.1 Ensure iptables packages are installed (Automated)
    - package_iptables_installed
    - service_iptables_enabled

    ###### 3.5.3.1.2 Ensure nftables is not installed (Automated)
    - service_nftables_disabled
    - package_nftables_removed

    ###### 3.5.3.1.3 Ensure Uncomplicated Firewall is not installed or disabled (Automated)
    # - package_ufw_removed # (Duplicate of above)

    #### 3.5.3.2 Configure IPv4 iptables ####
    ###### 3.5.3.2.1 Ensure default deny firewall policy (Automated)
    - set_iptables_default_rule

    ###### 3.5.3.2.2 Ensure loopback traffic is configured (Automated)
    # Needs rules

    ##### 3.5.3.2.3 Ensure outbound and established connections are configured (Manual)
    # Skip due to being a manual test

    ##### 3.5.3.2.4 Ensure firewall rules exist for all open ports (Manual)
    # Skip due to being a manual test

    #### 3.5.3.3 Configure IPv6 ip6tables ####
    # 3.5.3.3.1 Ensure IPv6 default deny firewall policy (Automated)
    - set_ip6tables_default_rule

    # 3.5.3.3.2 Ensure IPv6 loopback traffic is configured (Automated)
    # Needs rules

    # 3.5.3.3.3 Ensure IPv6 outbound and established connections are configured (Manual)
    # Skip due to being a manual test

    # 3.5.3.3.4 Ensure IPv6 firewall rules exist for all open ports (Manual)
    # Skip due to being a manual test

    # 4 Logging and Auditing #
    ## 4.1 Configure System Accounting (auditd) ##
    ### 4.1.1 Ensure auditing is enabled ###
    #### 4.1.1.1 Ensure auditd is installed (Automated)
    # Skip due to being Level 2

    #### 4.1.1.2 Ensure auditd service is enabled (Automated)
    # Skip due to being Level 2

    #### 4.1.1.3 Ensure auditing for processes that start prior to auditd is enabled (Automated)
    # Skip due to being Level 2

    #### 4.1.1.4 Ensure audit_backlog_limit is sufficient (Automated)
    # Skip due to being Level 2

    ## 4.1.2 Configure Data Retention ##
    #### 4.1.2.1 Ensure audit log storage size is configured (Automated)
    # Skip due to being Level 2

    #### 4.1.2.2 Ensure audit logs are not automatically deleted (Automated)
    # Skip due to being Level 2

    #### 4.1.2.3 Ensure system is disabled when audit logs are full (Automated)
    # Skip due to being Level 2

    ### 4.1.3 Ensure events that modify date and time information are collected (Automated)
    # Skip due to being Level 2

    ### 4.1.4 Ensure events that modify user/group information are collected (Automated)
    # Skip due to being Level 2

    ### 4.1.5 Ensure events that modify the system's network environment are collected (Automated)
    # Skip due to being Level 2

    ### 4.1.6 Ensure events that modify the system's Mandatory Access Controls are collected (Automated)
    # Skip due to being Level 2

    ### 4.1.7 Ensure login and logout events are collected (Automated)
    # Skip due to being Level 2

    ### 4.1.8 Ensure session initiation information is collected (Automated)
    # Skip due to being Level 2

    ### 4.1.9 Ensure discretionary access control permission modification events are collected (Automated)
    # Skip due to being Level 2

    ### 4.1.10 Ensure unsuccessful unauthorized file access attempts are collected (Automated)
    # Skip due to being Level 2

    ### 4.1.11 Ensure use of privileged commands is collected (Automated)
    # Skip due to being Level 2

    ### 4.1.12 Ensure successful file system mounts are collected (Automated)
    # Skip due to being Level 2

    ### 4.1.13 Ensure file deletion events by users are collected (Automated)
    # Skip due to being Level 2

    ### 4.1.14 Ensure changes to system administration scope (sudoers) is collected (Automated)
    # Skip due to being Level 2

    ### 4.1.15 Ensure system administrator command executions (sudo) are collected (Automated)
    # Skip due to being Level 2

    ### 4.1.16 Ensure kernel module loading and unloading is collected (Automated)
    # Skip due to being Level 2

    ### 4.1.17 Ensure the audit configuration is immutable (Automated)
    # Skip due to being Level 2

    ## 4.2 Configure Logging ##
    ### 4.2.1 Configure rsyslog ###
    #### 4.2.1.1 Ensure rsyslog is installed (Automated)
    - package_rsyslog_installed

    #### 4.2.1.2 Ensure rsyslog Service is enabled (Automated)
    - service_rsyslog_enabled

    #### 4.2.1.3 Ensure logging is configured (Manual)
    # Skip due to being a manual test

    #### 4.2.1.4 Ensure rsyslog default file permissions configured (Automated)
    # Needs rules: rsyslog_filecreatemode

    #### 4.2.1.5 Ensure rsyslog is configured to send logs to a remote log host (Automated)
    - rsyslog_remote_loghost

    #### 4.2.1.6 Ensure remote rsyslog messages are only accepted on designated log hosts. (Manual)
    # Skip due to being a manual test

    ## 4.2.2 Configure journald ##
    #### 4.2.2.1 Ensure journald is configured to send logs to rsyslog (Automated)
    # Needs rule: forward_to_syslog

    #### 4.2.2.2 Ensure journald is configured to compress large log files (Automated)
    # Needs rule: compress_large_logs

    #### 4.2.2.3 Ensure journald is configured to write logfiles to persistent disk (Automated)
    # Needs rule: persistent_storage

    ### 4.2.3 Ensure permissions on all logfiles are configured (Automated)
    # Needs rule: all_logfile_permissions

    ## 4.3 Ensure logrotate is configured (Manual)
    # Skip due to being a manual test

    ## 4.4 Ensure logrotate assigns appropriate permissions (Automated)
    # Needs variable? Leave manual?
    # Needs rule: ensure_logrotate_permissions

    # 5 Access, Authentication and Authorization #
    ## 5.1 Configure time-based job schedulers ##
    ### 5.1.1 Ensure cron daemon is enabled and running (Automated)
    - service_cron_enabled

    ### 5.1.2 Ensure permissions on /etc/crontab are configured (Automated)
    - file_permissions_crontab
    - file_owner_crontab
    - file_groupowner_crontab

    ### 5.1.3 Ensure permissions on /etc/cron.hourly are configured (Automated)
    - file_permissions_cron_hourly
    - file_owner_cron_hourly
    - file_groupowner_cron_hourly

    ### 5.1.4 Ensure permissions on /etc/cron.daily are configured (Automated)
    - file_permissions_cron_daily
    - file_owner_cron_daily
    - file_groupowner_cron_daily

    ### 5.1.5 Ensure permissions on /etc/cron.weekly are configured (Automated)
    - file_permissions_cron_weekly
    - file_owner_cron_weekly
    - file_groupowner_cron_weekly

    ### 5.1.6 Ensure permissions on /etc/cron.monthly are configured (Automated)
    - file_permissions_cron_monthly
    - file_owner_cron_monthly
    - file_groupowner_cron_monthly

    ### 5.1.7 Ensure permissions on /etc/cron.d are configured (Automated)
    - file_permissions_cron_d
    - file_owner_cron_d
    - file_groupowner_cron_d

    ### 5.1.8 Ensure cron is restricted to authorized users (Automated)
    - file_permissions_cron_allow
    - file_owner_cron_allow
    - file_groupowner_cron_allow

    ### 5.1.9 Ensure at is restricted to authorized users (Automated)
    - file_permissions_at_allow
    - file_owner_at_allow
    - file_groupowner_at_allow

    ## 5.2 Configure SSH Server ##
    ### 5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured (Automated)
    - file_permissions_sshd_config
    - file_owner_sshd_config
    - file_groupowner_sshd_config

    ### 5.2.2 Ensure permissions on SSH private host key files are configured (Automated)
    - file_permissions_sshd_private_key

    ### 5.2.3 Ensure permissions on SSH public host key files are configured (Automated)
    - file_permissions_sshd_pub_key

    ### 5.2.4 Ensure SSH LogLevel is appropriate (Automated)
    - sshd_set_loglevel_info

    ### 5.2.5 Ensure SSH X11 forwarding is disabled (Automated)
    # Skip due to being Level 2

    ### 5.2.6 Ensure SSH MaxAuthTries is set to 4 or less (Automated)
    - sshd_max_auth_tries_value=4
    - sshd_set_max_auth_tries

    ### 5.2.7 Ensure SSH IgnoreRhosts is enabled (Automated)
    - sshd_disable_rhosts

    ### 5.2.8 Ensure SSH HostbasedAuthentication is disabled (Automated)
    - disable_host_auth

    ### 5.2.9 Ensure SSH root login is disabled (Automated)
    - sshd_disable_root_login

    ### 5.2.10 Ensure SSH PermitEmptyPasswords is disabled (Automated)
    - sshd_disable_empty_passwords

    ### 5.2.11 Ensure SSH PermitUserEnvironment is disabled (Automated)
    - sshd_do_not_permit_user_env

    ### 5.2.12 Ensure only strong Ciphers are used (Automated)
    # Needs variable value: sshd_approved_ciphers=ubuntu_fips
    - sshd_use_approved_ciphers

    ### 5.2.13 Ensure only strong MAC algorithms are used (Automated)
    # Needs variable value: sshd_approved_macs=ubuntu_fips
    - sshd_use_approved_macs

    ### 5.2.14 Ensure only strong Key Exchange algorithms are used (Automated)
    # Needs variable
    # Needs rule

    ### 5.2.15 Ensure SSH Idle Timeout Interval is configured (Automated)
    - sshd_idle_timeout_value=5_minutes
    - sshd_set_idle_timeout
    - var_sshd_set_keepalive=3
    - sshd_set_keepalive

    ### 5.2.16 Ensure SSH LoginGraceTime is set to one minute or less (Automated)
    # Needs variable
    # Needs rule

    ### 5.2.17 Ensure SSH access is limited (Automated)
    # Needs rules

    ### 5.2.18 Ensure SSH warning banner is configured (Automated)
    # Needs rule

    ### 5.2.19 Ensure SSH PAM is enabled (Automated)
    # Needs rule

    ### 5.2.20 Ensure SSH AllowTcpForwarding is disabled (Automated)
    # Skip due to being Level 2

    ### 5.2.21 Ensure SSH MaxStartups is configured (Automated)
    # Needs rule

    ### 5.2.22 Ensure SSH MaxSessions is limited (Automated)
    - var_sshd_max_sessions=10
    - sshd_set_max_sessions

    ## 5.3 Configure PAM ##
    ### 5.3.1 Ensure password creation requirements are configured (Automated)
    - package_pam_pwquality_installed
    - var_password_pam_minlen=14
    - accounts_password_pam_minlen
    - var_password_pam_minclass=4
    - accounts_password_pam_minclass
    - var_password_pam_dcredit=1
    - accounts_password_pam_dcredit
    - var_password_pam_ucredit=1
    - accounts_password_pam_ucredit
    - var_password_pam_ocredit=1
    - accounts_password_pam_ocredit
    - var_password_pam_lcredit=1
    - accounts_password_pam_lcredit
    - var_password_pam_retry=3
    - accounts_password_pam_retry

    ### 5.3.2 Ensure lockout for failed password attempts is configured (Automated)
    # Needs variable: var_accounts_passwords_pam_tally2_deny=5
    - accounts_passwords_pam_tally2

    ### 5.3.3 Ensure password reuse is limited (Automated)
    # Needs variable
    - accounts_password_pam_pwhistory_remember

    ### 5.3.4 Ensure password hashing algorithm is SHA-512 (Automated)
    - accounts_password_all_shadowed_sha512

    ## 5.4 User Accounts and Environment ##
    ### 5.4.1 Set Shadow Password Suite Parameters ###
    #### 5.4.1.1 Ensure password expiration is 365 days or less (Automated)
    - var_accounts_maximum_age_login_defs=365
    # Needs variable: var_accounts_password_set_max_life_existing=365
    - accounts_maximum_age_login_defs
    - accounts_password_set_max_life_existing

    #### 5.4.1.2 Ensure minimum days between password changes is configured (Automated)
    - var_accounts_minimum_age_login_defs=1
    # Needs variable: var_accounts_password_set_min_life_existing=1
    - accounts_minimum_age_login_defs
    - accounts_password_set_min_life_existing

    #### 5.4.1.3 Ensure password expiration warning days is 7 or more (Automated)
    - var_accounts_password_warn_age_login_defs=7
    - accounts_password_warn_age_login_defs

    #### 5.4.1.4 Ensure inactive password lock is 30 days or less (Automated)
    - var_account_disable_post_pw_expiration=30
    - account_disable_post_pw_expiration

    #### 5.4.1.5 Ensure all users last password change date is in the past (Automated)
    # Needs rule: last_change_date_in_past

    ### 5.4.2 Ensure system accounts are secured (Automated)
    - no_shelllogin_for_systemaccounts

    ### 5.4.3 Ensure default group for the root account is GID 0 (Automated)
    # Needs rule: accounts_no_gid_except_zero

    ### 5.4.4 Ensure default user umask is 027 or more restrictive (Automated)
    - accounts_umask_etc_csh_cshrc
    - accounts_umask_etc_login_defs
    - accounts_umask_etc_profile
    - accounts_umask_etc_bashrc
    - accounts_umask_interactive_users

    ### 5.4.5 Ensure default user shell timeout is 900 seconds or less (Automated)
    - accounts_tmout

    ## 5.5 Ensure root login is restricted to system console (Manual)
    # Skip due to being a manual test

    ## 5.6 Ensure access to the su command is restricted (Automated)
    - use_pam_wheel_for_su

    # 6 System Maintenance #
    ## 6.1 System File Permissions ##
    ### 6.1.1 Audit system file permissions (Manual)
    # Skip due to being Level 2

    ### 6.1.2 Ensure permissions on /etc/passwd are configured (Automated)
    - file_owner_etc_passwd
    - file_groupowner_etc_passwd
    - file_permissions_etc_passwd

    ### 6.1.3 Ensure permissions on /etc/gshadow- are configured (Automated)
    - file_owner_backup_etc_gshadow
    - file_groupowner_backup_etc_gshadow
    - file_permissions_backup_etc_gshadow

    ### 6.1.4 Ensure permissions on /etc/shadow are configured (Automated)
    - file_owner_etc_shadow
    - file_groupowner_etc_shadow
    - file_permissions_etc_shadow

    ### 6.1.5 Ensure permissions on /etc/group are configured (Automated)
    - file_owner_etc_group
    - file_groupowner_etc_group
    - file_permissions_etc_group

    ### 6.1.6 Ensure permissions on /etc/passwd- are configured (Automated)
    - file_owner_backup_etc_passwd
    - file_groupowner_backup_etc_passwd
    - file_permissions_backup_etc_passwd

    ### 6.1.7 Ensure permissions on /etc/shadow- are configured (Automated)
    - file_owner_backup_etc_shadow
    - file_groupowner_backup_etc_shadow
    - file_permissions_backup_etc_shadow

    ### 6.1.8 Ensure permissions on /etc/group- are configured (Automated)
    - file_owner_backup_etc_group
    - file_groupowner_backup_etc_group
    - file_permissions_backup_etc_group

    ### 6.1.9 Ensure permissions on /etc/gshadow are configured (Automated)
    - file_owner_etc_gshadow
    - file_groupowner_etc_gshadow
    - file_permissions_etc_gshadow

    ### 6.1.10 Ensure no world writable files exist (Automated)
    - file_permissions_unauthorized_world_writable

    ### 6.1.11 Ensure no unowned files or directories exist (Automated)
    # Needs variable
    - no_files_unowned_by_user

    ### 6.1.12 Ensure no ungrouped files or directories exist (Automated)
    # Needs variable
    # Needs rule: no_ungrouped_files_or_dirs

    ### 6.1.13 Audit SUID executables (Manual)
    # Skip due to being a manual test

    ### 6.1.14 Audit SGID executables (Manual)
    # Skip due to being a manual test

    ## 6.2 User and Group Settings ##
    ### 6.2.1 Ensure password fields are not empty (Automated)
    - no_empty_passwords

    ### 6.2.2 Ensure root is the only UID 0 account (Automated)
    - accounts_no_uid_except_zero

    ### 6.2.3 Ensure root PATH Integrity (Automated)
    - accounts_root_path_dirs_no_write

    ### 6.2.4 Ensure all users' home directories exist (Automated)
    - accounts_user_interactive_home_directory_exists

    ### 6.2.5 Ensure users' home directories permissions are 750 or more restrictive (Automated)
    - file_permissions_home_directories
    # Needs variable
    # Needs rule: adduser_home_directories_umask
    # Needs rule: useradd_home_directories_umask

    ### 6.2.6 Ensure users own their home directories (Automated)
    # Needs rule: accounts_users_own_home_directories

    ### 6.2.7 Ensure users' dot files are not group or world writable (Automated)
    - accounts_user_dot_user_ownership
    - accounts_user_dot_group_ownership
    # Needs rule: no_group_world_readable_dot_files

    ### 6.2.8 Ensure no users have .forward files (Automated)
    # Needs variable
    # Needs rule: no_forward_files

    ### 6.2.9 Ensure no users have .netrc files (Automated)
    # Needs variable
    - no_netrc_files

    ### 6.2.10 Ensure users' .netrc Files are not group or world accessible (Automated)
    # Needs rule: no_group_world_readable_netrc_files

    ### 6.2.11 Ensure no users have .rhosts files (Automated)
    - no_rsh_trust_files

    ### 6.2.12 Ensure all groups in /etc/passwd exist in /etc/group (Automated)
    # Needs rule: all_etc_passwd_groups_exist_in_etc_group

    ### 6.2.13 Ensure no duplicate UIDs exist (Automated)
    # Needs rule: no_duplicate_uids

    ### 6.2.14 Ensure no duplicate GIDs exist (Automated)
    # Needs rule: no_duplicate_gids

    ### 6.2.15 Ensure no duplicate user names exist (Automated)
    # Needs rule: no_duplicate_user_names

    ### 6.2.16 Ensure no duplicate group names exist (Automated)
    # Needs rule: no_duplicate_group_names

    ### 6.2.17 Ensure shadow group is empty (Automated)
    # Needs rule: ensure_shadow_group_empty
