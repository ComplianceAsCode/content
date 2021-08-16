documentation_complete: true

metadata:
    version: 1.0.0
    SMEs:
        - truzzon

reference: https://www.cisecurity.org/cis-benchmarks/#suse_linux


title: 'CIS SUSE Linux Enterprise 12 Benchmark'

description: |-
    This profile defines a baseline that aligns to the Center for Internet Security®
    SUSE Linux Enterprise 12 Benchmark™, v3.0.0, released 04-27-2021.

    This profile includes Center for Internet Security®
    SUSE Linux Enterprise 12 CIS Benchmarks™ content.

selections:

    ## 1.1 Filesystem Configuration
    ### 1.1.1 Disable unused filesystems

    #### 1.1.1.1 Ensure mounting of squashfs filesystems is disabled (Automated)
    - kernel_module_squashfs_disabled

    #### 1.1.1.2 Ensure mounting of udf filesystems is disabled (Automated)
    - kernel_module_udf_disabled

    ### 1.1.2 Ensure /tmp is configured (Automated)
    - partition_for_tmp

    ### 1.1.3 Ensure noexec option set on /tmp partition (Automated)
    - mount_option_tmp_noexec

    ### 1.1.4 Ensure nodev option set on /tmp partition (Automated)
    - mount_option_tmp_nodev

    ### 1.1.5 Ensure nosuid option set on /tmp partition (Automated)
    - mount_option_tmp_nosuid

    ### 1.1.6 Ensure /dev/shm is configured (Automated)
    # No Rule required?

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

    ### 1.1.12 Ensure noexec option set on /var/tmp partition (Automated)
    - mount_option_var_tmp_noexec

    ### 1.1.13 Ensure nodev option set on /var/tmp partition (Automated)
    - mount_option_var_tmp_nodev

    ### 1.1.14 Ensure nosuid option set on /var/tmp partition (Automated)
    - mount_option_var_tmp_nosuid

    ### 1.1.15 Ensure separate partition exists for /var/log (Automated)
    - partition_for_var_log

    ### 1.1.16 Ensure separate partition exists for /var/log/audit (Automated)
    - partition_for_var_log_audit

    ### 1.1.17 Ensure separate partition exists for /home (Automated)
    - partition_for_home

    ### 1.1.18 Ensure nodev option set on /home partition (Automated)
    - mount_option_home_nodev

    ### 1.1.19 Ensure noexec option set on removable media partitions (Manual)
    - mount_option_noexec_removable_partitions

    ### 1.1.20 Ensure nodev option set on removable media partitions (Manual)
    - mount_option_nodev_removable_partitions

    ### 1.1.21 Ensure nosuid option set on removable media partitions (Manual)
    - mount_option_nosuid_removable_partitions

    ### 1.1.22 Ensure sticky bit is set on all world-writable directories (Automated)
    - dir_perms_world_writable_sticky_bits

    ### 1.1.23 Disable Automounting (Automated)
    - service_autofs_disabled

    ## 1.2 Configure Software Updates
    ### 1.2.1 Ensure GPG keys are configured (Manual)
    # NEEDS RULE FOR SUSE

    ### 1.2.2 Ensure package manager repositories are configured (Manual)
    # NEEDS RULE -

    ### 1.2.3 Ensure gpgcheck is globally activated (Automated)
    - ensure_gpgcheck_globally_activated

    ## 1.3 Filesystem Integrity Checking
    ### 1.3.1 Ensure AIDE is installed (Automated)
    - package_aide_installed

    ### 1.3.2 Ensure filesystem integrity is regularly checked (Automated)
    - aide_periodic_cron_checking

    ## 1.4 Secure Boot Settings
    ### 1.4.1 Ensure bootloader password is set (Automated)
    - grub2_password

    ### 1.4.2 Ensure permissions on bootloader config are configured (Automated)
    #### chown root:root /boot/grub2/grub.cfg
    - file_owner_grub2_cfg
    - file_groupowner_grub2_cfg

    #### chmod 600 /boot/grub2/grub.cfg
    - file_permissions_grub2_cfg

    #### chown root:root /boot/grub2/grubenv
    # NEED RULE -

    #### chmod 600 /boot/grub2/grubenv
    # NEED RULE -

    ### 1.4.3 Ensure authentication required for single user mode (Automated)
    #### ExecStart=-/usr/lib/systemd/systemd-sulogin-shell rescue
    - require_singleuser_auth

    #### ExecStart=-/usr/lib/systemd/systemd-sulogin-shell emergency
    - require_emergency_target_auth

    ## 1.5 Additional Process Hardening
    ### 1.5.1 Ensure core dumps are restricted (Automated)
    #### * hard core 0
    - disable_users_coredumps

    #### fs.suid_dumpable = 0
    - sysctl_fs_suid_dumpable

    #### ProcessSizeMax=0
    - coredump_disable_backtraces

    #### Storage=none
    - coredump_disable_storage

    ### 1.5.2 Ensure XD/NS support is enabled (Automated)
    #### No configuration required for 64-bit systems

    ### 1.5.3 Ensure address space layout randomization (ASLR) is enabled (Automated)
    - sysctl_kernel_randomize_va_space

    ### 1.5.4 Ensure prelink is disabled (Automated)
    # NEED RULE -

    ## 1.7 Mandatory Access Control
    ### 1.7.1 Configure AppArmor

    #### 1.7.1.1 Ensure AppArmor is installed (Automated)
    # NEED RULE -

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
    # chmod 644 /etc/motd
    - file_permissions_etc_motd

    #### 1.8.1.5 Ensure permissions on /etc/issue are configured (Automated)
    # chmod 644 /etc/issue
    - file_permissions_etc_issue

    #### 1.8.1.6 Ensure permissions on /etc/issue.net are configured (Automated)
    # Previously addressed via 'rpm_verify_permissions' rule

    ### 1.8.2 Ensure GDM login banner is configured (Automated)
    #### banner-message-enable=true
    - dconf_gnome_banner_enabled

    #### banner-message-text='<banner message>'
    - dconf_gnome_login_banner_text

    ## 1.9 Ensure updates, patches, and additional security software are installed (UnAutomated)
    - security_patches_up_to_date

    ## 1.10 Ensure GDM is removed or login is configured (Automated)
    ## Need Rule

    # 2 Services
    ## 2.1 inetd Services
    ### 2.1.1 Ensure xinetd is not installed (Automated)
    - package_xinetd_removed

    ## 2.2 Special Purpose Services
    ### 2.2.1 Time Synchronization
    #### 2.2.1.1 Ensure time synchronization is in use (Manual)
    - package_chrony_installed

    #### 2.2.1.2 Ensure systemd-timesyncd is configured (Manual)
    # Not needed. Checking for chrony

    #### 2.2.1.3 Ensure chrony is configured (Automated)
    - service_chronyd_enabled
    - chronyd_specify_remote_server
    - chronyd_run_as_chrony_user

    ### 2.2.2 Ensure X Window System is not installed (Automated)
    - package_xorg-x11-server-common_removed
    - xwindows_runlevel_target

    ### 2.2.3 Ensure Avahi Server is not installed (Automated)
    # Need Correct Rule!
    - service_avahi-daemon_disabled

    ### 2.2.4 Ensure CUPS is not installed (Automated)
    # Need Correct Rule!
    - service_cups_disabled

    ### 2.2.5 Ensure DHCP Server is not installed (Automated)
    # Need Correct Rule!
    - service_dhcpd_disabled

    ### 2.2.6 Ensure LDAP server is not installed (Automated)
    # Need Correct Rule!
    - package_openldap-servers_removed

    ### 2.2.7 Ensure nfs-utils is not installed or the nfs-server service is masked (Automated)
    # Need Rule

    ### 2.2.8 Ensure rpcbind is not installed or the rpcbind services are masked (Automated)
    # Need Correct Rule!
    - service_rpcbind_disabled

    ### 2.2.9 Ensure DNS Server is not installed (Automated)
    # Need Correct Rule!
    - service_named_disabled

    ### 2.2.10 Ensure FTP Server is not installed (Automated)
    - package_vsftpd_removed

    ### 2.2.11 Ensure HTTP server is not installed (Automated)
    - package_httpd_removed

    ### 2.2.12 Ensure IMAP and POP3 server is not installed (Automated)
    - package_dovecot_removed

    ### 2.2.13 Ensure Samba is not installed (Automated)
    - package_samba_removed

    ### 2.2.14 Ensure HTTP Proxy Server is not installed (Automated)
    - package_squid_removed

    ### 2.2.15 Ensure net-snmp is not installed (Automated)
    - package_net-snmp_removed

    ### 2.2.16 Ensure mail transfer agent is configured for local-only mode (Automated)
    - postfix_network_listening_disabled

    ### 2.2.17 Ensure rsync is not installed or the rsyncd service is masked (Automated)
    # Need Correct Rule!
    - service_rsyncd_disabled

    ### 2.2.18 Ensure NIS server is not installed (Automated)
    - package_ypserv_removed

    ### 2.2.19 Ensure telnet-server is not installed (Automated)
    - package_telnetd_removed

    ## 2.3 Service Clients
    ### 2.3.1 Ensure NIS Client is not installed (Automated)
    - package_ypbind_removed

    ### 2.3.2 Ensure rsh client is not installed (Automated)
    - package_rsh_removed

    ### 2.3.3 Ensure talk client is not installed (Automated)
    - package_talk_removed

    ### 2.3.4 Ensure telnet client is not installed (Automated)
    - package_telnet_removed

    ### 2.3.5 Ensure LDAP client is not installed (Automated)
    - package_openldap-clients_removed

    # 3 Network Configuration
    ## 3.1 Disable unused network protocols
    ### 3.1.1 Disable IPv6
    - grub2_ipv6_disable_argument

    ### 3.1.2 Ensure wireless interfaces are disabled
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

    ### 3.3.9 Ensure IPv6 router advertisements are not accepted (Automated)
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


    #### 3.5.1.2 Ensure nftables is not installed or stopped and masked (Automated)
    ## Need Rule!
    ##- package_nftables_removed

    #### 3.5.1.3 Ensure firewalld service is enabled and running (Automated)
    - service_firewalld_enabled

    #### 3.5.1.4 Ensure default zone is set (Automated)
    - set_firewalld_default_zone

    #### 3.5.1.5 Ensure network interfaces are assigned to appropriate zone (Manual)
    # Need Rule

    #### 3.5.1.6 Ensure unnecessary services and ports are not accepted (Manual)
    # Need Rule

    ### 3.5.2 Configure nftables
    #### 3.5.2.1 Ensure nftables is installed (Automated)
    # Need Rule

    #### 3.5.2.2 Ensure firewalld is not installed (Automated)
    # # Need Rule

    #### 3.5.2.3 Ensure iptables are flushed (Manual)
    # Need Rule

    #### 3.5.2.4 Ensure a table exists (Automated)
    # Need Rule

    #### 3.5.2.5 Ensure a base chain exists (Automated)
    # Need Rule

    #### 3.5.2.6 Ensure loopback traffic is configured (Automated)
    # Need Rule

    #### 3.5.2.7 Ensure outbound and established connections are configured (Manual)
    # Need Rule

    #### 3.5.2.8 Ensure default deny firewall policy (Automated)
    # Need Rule

    #### 3.5.2.9 Ensure nftables is enabled (Automated)
    # Need Rule

    #### 3.5.2.10 Ensure nftables rules are permanent (Automated)
    # Need Rule

    ### 3.5.3 Configure iptables
    #### 3.5.3.1 Configure software
    ##### 3.5.3.1.1 Ensure iptables is installed (Automated)
    - package_iptables_installed
    ##### Ensure iptables is enabled and running
    - service_iptables_enabled
    - service_ip6tables_enabled

    ##### 3.5.3.1.2 Ensure nftables is not installed (Automated)
    # Need Rule

    ##### 3.5.3.1.3 Ensure firewalld is not installed or stopped and masked (Automated)
    # Need Rule

    #### 3.5.3.2 Configure IPv4 iptables
    ##### 3.5.3.2.1 Ensure default deny firewall policy (Automated)
    - set_iptables_default_rule
    ##### 3.5.3.2.2 Ensure loopback traffic is configured (Automated)
    # Manual check and remmdiation by admin required


    ##### 3.5.3.2.3 Ensure outbound and established connections are configured (Manual)
    # Need Rule

    ##### 3.5.3.2.4 Ensure firewall rules exist for all open ports (Manual)
    # Manual check and remmdiation by admin required

    #### 3.5.3.3 Configure IPv6 iptables
    ##### 3.5.3.3.1 Ensure IPv6 default deny firewall policy (Automated)
    - set_ip6tables_default_rule

    ##### 3.5.3.3.2 Ensure IPv6 loopback traffic is configured (Automated)
    # Need Rule

    ##### 3.5.3.3.3 Ensure IPv6 outbound and established connections are configured (Manual)
    # Need Rule

    ##### 3.5.3.3.4 Ensure IPv6 firewall rules exist for all open ports (Automated)
    # Manual check and remmdiation by admin required

    # 4 Logging and Auditing

    ## 4.1 Configure System Accounting (auditd)
    ### 4.1.1 Ensure Auditing is enabled
    ###  4.1.1.1 Ensure auditd is installed (Automated)
    - package_audit_installed

    #### 4.1.1.2 Ensure auditd service is enabled and running (Automated)
    - service_auditd_enabled

    #### 4.1.1.3 Ensure auditing for processes that start prior to auditd is enabled (Automated)
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

    ### 4.1.3 Ensure events that modify date and time information are collected (Automated)
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

    ### 4.1.4 Ensure events that modify user/group information are collected (Automated)

    ### 4.1.5 Ensure events that modify the system's network enironment are collected (Automated)
    - audit_rules_networkconfig_modification

    ### 4.1.6 Ensure events that modify the system's Mandatory Access Control are collected (Automated)
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


    ### 4.1.10 Ensure unsuccessful unauthorized file access attempts are
    ###        collected (Automated)
    # Need Rule

    ### 4.1.11 Ensure use of privileged commands is collected (Automated)
    # Need Rule

    ### 4.1.12 Ensure successful file system mounts are collected (Automated)
    # Need Rule

    ### 4.1.13 Ensure file deletion events by users are collected
    ###        (Automated)
    # Need Rule

    ### 4.1.14 Ensure changes to system administration scope
    ###       (sudoers) is collected (Automated)
    - audit_rules_sysadmin_actions

    ### 4.1.15 Ensure system administrator actions (sudolog) are
    ###        collected (Automated)
    # Need Rule

    ### 4.1.16 Ensure kernel module loading and unloading is collected
    ###        (Automated)
    - audit_rules_kernel_module_loading

    ### 4.1.17 Ensure the audit configuration is immutable (Automated)
    - audit_rules_immutable

    ## 4.2 Configure Logging
    ### 4.2.1 Configure rsyslog
    #### 4.2.1.1 Ensure rsyslog is installed (Automated)
    - package_rsyslog_installed

    #### 4.2.1.2 Ensure rsyslog Service is enabled and running(Automated)
    - service_rsyslog_enabled

    #### 4.2.1.3 Ensure rsyslog default file permissions configured (Automated)
    - rsyslog_files_groupownership
    - rsyslog_files_ownership
    - rsyslog_files_permissions

    #### 4.2.1.4 Ensure logging is configured (Manual)
    # Manual check and remmdiation by admin required

    #### 4.2.1.5 Ensure rsyslog is configured to send logs to a remote
    ####         log host (Automated)
    - rsyslog_remote_loghost

    #### 4.2.1.6 Ensure remote rsyslog messages are only accepted on
    ####         designated log hosts (Manual)

    ### 4.2.2 Configure journald
    #### 4.2.2.1 Ensure journald is configured to send logs to
    ####         rsyslog (Automated)
    # Need Rule

    #### 4.2.2.2 Ensure journald is configured to compress large
    ####         log files (Automated)
    # Need Rule

    #### 4.2.2.3 Ensure journald is configured to write logfiles to
    ####         persistent disk (Automated)
    # Need Rule

    ### 4.2.3 Ensure permissions on all logfiles are configured (Automated)
    # Need Rule

    ### 4.2.4 Ensure logrotate is configured (Not Automated)
    # Manual check and remmdiation by admin required

    # 5 Access, Authentication and Authorization
    ## 5.2 Configure time-based job schedulers
    ### 5.2.1 Ensure cron daemon is enabled (Automated)
    - service_cron_enabled

    ### 5.2.2 Ensure permissions on /etc/crontab are configured (Automated)
    # chown root:root /etc/crontab
    - file_owner_crontab
    - file_groupowner_crontab
    # chmod 600 /etc/crontab
    - file_permissions_crontab

    ### 5.2.3 Ensure permissions on /etc/cron.hourly are configured (Automated)
    # chown root:root /etc/cron.hourly
    - file_owner_cron_hourly
    - file_groupowner_cron_hourly
    # chmod 700 /etc/cron.hourly
    - file_permissions_cron_hourly

    ### 5.2.4 Ensure permissions on /etc/cron.daily are configured (Automated)
    # chown root:root /etc/cron.daily
    - file_owner_cron_daily
    - file_groupowner_cron_daily
    # chmod 700 /etc/cron.daily
    - file_permissions_cron_daily

    ### 5.2.5 Ensure permissions on /etc/cron.weekly are configured (Automated)
    # chown root:root /etc/cron.weekly
    - file_owner_cron_weekly
    - file_groupowner_cron_weekly
    # chmod 700 /etc/cron.weekly
    - file_permissions_cron_weekly

    ### 5.2.6 Ensure permissions on /etc/cron.monthly are configured (Automated)
    # chown root:root /etc/cron.monthly
    - file_owner_cron_monthly
    - file_groupowner_cron_monthly
    # chmod 700 /etc/cron.monthly
    - file_permissions_cron_monthly

    ### 5.2.7 Ensure permissions on /etc/cron.d are configured (Automated)
    # chown root:root /etc/cron.d
    - file_owner_cron_d
    - file_groupowner_cron_d
    # chmod 700 /etc/cron.d
    - file_permissions_cron_d

    ### 5.2.8 Ensure cron is restricted to authorized users (Automated)
    # chown root:root /etc/cron.allow
    - file_owner_cron_allow
    - file_groupowner_cron_allow

    # chmod 600 /etc/cron.allow
    # not yet implemented
    #- file_permissions_cron_allow

    ### 5.2.9 Ensure at is restricted to authorized users (Automated)
    # Need Rule

    ## 5.3 SSH Server Configuration
    ### 5.3.1 Ensure permissions on /etc/ssh/sshd_config are configured (Automated)
    # chown root:root /etc/ssh/sshd_config
    - file_owner_sshd_config
    - file_groupowner_sshd_config
    # chmod 600 /etc/ssh/sshd_config
    - file_permissions_sshd_config

    ### 5.3.2 Ensure permissions on SSH private host key files are
    ###       configured (Automated)
    - file_permissions_sshd_private_key
    # TO DO: check owner of private keys in /etc/ssh is root:root

    ### 5.3.3 Ensure permissions on SSH public host key files are configured
    ###      (Automated)
    - file_permissions_sshd_pub_key
    # TO DO: check owner of pub keys in /etc/ssh is root:root

    ### 5.3.4 Ensure SSH access is limited (Automated)
    # NEED RULE!

    ### 5.3.5 Ensure SSH LogLevel is appropriate (Automated)
    - sshd_set_loglevel_info

    ### 5.2.6 Ensure SSH X11 forward is diabled (Automated)
    - sshd_disable_x11_forwarding

    ### 5.3.7 Ensure SSH MaxAuthTries is set to 4 or less (Automated)
    - sshd_max_auth_tries_value=4
    - sshd_set_max_auth_tries

    ### 5.3.8 Ensure SSH IgnoreRhosts is enabled (Automated)
    - sshd_disable_rhosts

    ### 5.3.9 Ensure SSH HostbasedAuthentication is disabled (Automated)
    - disable_host_auth

    ### 5.3.10 Ensure SSH root login is disabled (Automated)
    - sshd_disable_root_login

    ### 5.3.11 Ensure SSH PermitEmptyPasswords is disabled (Automated)
    - sshd_disable_empty_passwords

    ### 5.3.12 Ensure SSH PermitUserEnvironment is disabled (Automated)
    - sshd_do_not_permit_user_env

    ### 5.3.13 Ensure only strong Ciphers are used (Automated)
    - sshd_use_strong_ciphers

    ### 5.3.14 Ensure only strong MAC algorithms are used (Automated)
    - sshd_use_strong_macs

    ### 5.3.15 Ensure only strong Key Exchange algorithms are used (Automated)
    # Not yet implemented.
    #- sshd_use_strong_kex

    ### 5.3.16 Ensure SSH Idle Timeout Interval is configured (Automated)
    # ClientAliveInterval 300
    - sshd_idle_timeout_value=5_minutes
    - sshd_set_idle_timeout

    # ClientAliveCountMax 0
    - var_sshd_set_keepalive=0
    - sshd_set_keepalive_0

    ### 5.3.17 Ensure SSH LoginGraceTime is set to one minute
    ###        or less (Automated)
    # Not yet implemented.
    #- var_sshd_set_login_grace_time=60
    #- sshd_set_login_grace_time

    ### 5.3.18 Ensure SSH warning banner is configured (Automated)
    - sshd_enable_warning_banner

    ### 5.3.19 Ensure SSH PAM is enabled (Automated)
    # Not yet implemented.
    # - sshd_use_pam

    ### 5.3.20 Ensure SSH AllowTcpForwarding is disabled (Automated)
    - sshd_disable_tcp_forwarding

    ### 5.3.21 Ensure SSH MaxStartups is configured (Automated)
    # Not yet implemented.
    #- var_sshd_set_max_startups=10:30:60
    #- sshd_set_max_startups

    ### 5.3.22 Ensure SSH MaxSessions is limited (Automated)
    - var_sshd_max_sessions=4
    - sshd_set_max_sessions

    ## 5.4 Configure PAM
    ### 5.4.1 Ensure password creation requirements are configured (Automated)
    # Configrure max retries
    - var_password_pam_retry=3
    - cracklib_accounts_password_pam_retry

    # Configure minlen
    - var_password_pam_minlen=14
    - cracklib_accounts_password_pam_minlen

    # Configure dcredit
    - cracklib_accounts_password_pam_dcredit

    # Configure ucredit
    - cracklib_accounts_password_pam_ucredit

    # Configure ocredit
    - cracklib_accounts_password_pam_ocredit

    # Configure lcredit
    - cracklib_accounts_password_pam_lcredit

    ### 5.4.2 Ensure lockout for failed password attempts is
    ###       configured (Automated)
    - accounts_passwords_pam_tally2

    ### 5.4.3Ensure password reuse is limited (Automated)
    - var_password_pam_remember=5
    - accounts_password_pam_pwhistory_remember

    ## 5.5 User Accountsand Environment
    ### 5.5.1 Set Shadow Password Suite Parameters
    #### 5.5.1.1 Ensure password hashing algorithm is SHA-512 (Automated)
    - set_password_hashing_algorithm_logindefs

    #### 5.5.1.2 Ensure password expiration is 365 days or less (Automated)
    - var_accounts_maximum_age_login_defs=365
    - accounts_maximum_age_login_defs

    #### 5.5.1.3 Ensure minimum days between password changes is 7
    ####         or more (Automated)
    - var_accounts_minimum_age_login_defs=7
    - accounts_minimum_age_login_defs

    #### 5.5.1.4 Ensure password expiration warning days is
    ####         7 or more (Automated)
    - var_accounts_password_warn_age_login_defs=7
    - accounts_password_warn_age_login_defs

    #### 5.5.1.5 Ensure inactive password lock is 30 days or less (Automated)
    # Need Rule

    #### 5.5.1.6 Ensure all users last password change date is
    ####         in the past (Automated)
    # Need Rule

    ### 5.5.2 Ensure system accounts are secured (Automated)
    # Need Rule

    ### 5.5.3 Ensure default group for the root account is
    ###       GID 0 (Automated)
    # Need Rule

    ### 5.5.4 Ensure default user shell timeout is 900 seconds
    ###       or less (Automated)
    # Need Rule

    ### 5.5.5 Ensure default user mask is 027 or more restrictive (Automated)
    - var_accounts_user_umask=027
    - accounts_umask_etc_login_defs
    - accounts_umask_etc_bashrc
    - accounts_umask_etc_profile
    - accounts_umask_interactive_users

    ## 5.5 Ensure root login is restricted to system console (Not Automated)
    - securetty_root_login_console_only

    ## 5.6 Ensure access to the su command is restricted (Automated)
    - use_pam_wheel_for_su

    # System Maintenance
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

    # chmod 640 /etc/shadow
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

    # chmod 644 /etc/passwd-
    - file_permissions_backup_etc_passwd

    ### 6.1.6 Ensure permissions on /etc/shadow- are configured (Automated)
    # chown root:root /etc/shadow-
    - file_owner_backup_etc_shadow
    - file_groupowner_backup_etc_shadow

    # chmod 0000 /etc/shadow-
    - file_permissions_backup_etc_shadow

    ### 6.1.7 Ensure permissions on /etc/group- are configured (Automated)
    # chown root:root /etc/group-
    - file_owner_backup_etc_group
    - file_groupowner_backup_etc_group

    # chmod 644 /etc/group-
    - file_permissions_backup_etc_group

    ### 6.1.8 Ensure no world writable files exist (Automated)
    - file_permissions_unauthorized_world_writable

    ### 6.1.9 Ensure no unowned files or directories exist (Automated)
    - no_files_unowned_by_user

    ### 6.1.10 Ensure no ungrouped files or directories exist (Automated)
    - file_permissions_ungroupowned

    ### 6.1.13 Audit SUID executables (Manual)
    - file_permissions_unauthorized_suid

    ### 6.1.14 Audit SGID executables (Manual)
    - file_permissions_unauthorized_sgid

    ## 6.2 User and Group Settings
    ### 6.2.1 Ensure accounts in /etc/passwd use shadowed passwords (Automated)
    # Need Rule

    ### 6.2.2 Ensure /etc/shadow password fields are not empty (Automated)
    # Need Rule

    ### 6.2.3 Ensure root is the only UID 0 account (Automated)
    # Need Rule

    ### 6.2.4 Ensure root PATH Integrity (Automated)
    # Rules are not 100% fitting the need. Might need additional rules.
    #- root_path_default
    #- accounts_root_path_dirs_no_write

    ### 6.2.5 Ensure all users' home directories exist (Automated)
    - accounts_user_interactive_home_directory_exists

    ### 6.2.6 Ensure users' home directories permissions are 750 or more
    ### restrictive (Automated)
    - accounts_users_home_files_permissions

    ### 6.2.7 Ensure users own their home directories (Automated)
    - accounts_users_home_files_ownership
    - accounts_users_home_files_groupownership

    ### 6.2.8 Ensure users' dot files are not group or world writable (Automated)
    # Need Rule

    ### 6.2.9 Ensure no users have .forward files (Automated)
    # Need Rule

    ### 6.2.10 Ensure no users have .netrc files (Automated)
    # Need Rule

    ### 6.2.11 Ensure users' .netrc Files are not group or world accessible (Automated)
    # Need Rule

    ### 6.2.12 Ensure no users have .rhosts files (Automated)
    # Need Rule

    ### 6.2.13 Ensure all groups in /etc/passwd exist in /etc/group (Automated)
    - gid_passwd_group_same

    ### 6.2.14 Ensure no duplicate UIDs exist (Automated)
    # Need Rule

    ### 6.2.15 Ensure no duplicate GIDs exist (Automated)
    # Need Rule

    ### 6.2.16 Ensure no duplicate user names exist (Automated)
    # Need Rule

    ### 6.2.17 Ensure no duplicate group names exist (Automated)
    # Need Rule

    ### 6.2.18 Ensure shadow group is empty (Automated)
    # Need Rule