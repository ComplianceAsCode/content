documentation_complete: true

title: 'CIS Ubuntu 18.04 LTS Benchmark'

description: |-
    This baseline aligns to the Center for Internet Security
    Ubuntu 18.04 LTS Benchmark, v1.0.0, released
    08-13-2018.

selections:

    ### Partitioning
    # NEEDS RULE - mount_option_home_nodev

    ## 1.1 Filesystem Configuration

    ### 1.1.1 Disable unused filesystems

    #### 1.1.1.1 Ensure mounting cramfs filesystems is disabled (Scored)
    - kernel_module_cramfs_disabled

    #### 1.1.1.2 Ensure mounting of freevxfs filesystems is limited (Scored)
    - kernel_module_freevxfs_disabled

    #### 1.1.1.3 Ensure mounting of jffs2 filesystems is disabled (Scored)
    - kernel_module_jffs2_disabled

    #### 1.1.1.4 Ensure mounting of hfs filesystems is disabled (Scored)
    - kernel_module_hfs_disabled

    #### 1.1.1.5 Ensure mounting of hfsplus filesystems is disabled (Scored)
    - kernel_module_hfsplus_disabled

    #### 1.1.1.6 Ensure mounting of udf filesystems is disabled (Scored)
    - kernel_module_udf_disabled

    ### 1.1.2 Ensure separate partitions exists for /tmp (Scored)
    - partition_for_tmp

    ### 1.1.3 Ensure nodev option set on /tmp partition (Scored)
    - mount_option_tmp_nodev

    ### 1.1.4 Ensure nosuid option set on /tmp partition (Scored)
    - mount_option_tmp_nosuid

    ### 1.1.5 Ensure separate partition exists for /var (Scored)
    - partition_for_var

    ### 1.1.6 Ensure separate partition exists for /var/tmp (Scored)
    - partition_for_var_tmp

    ### 1.1.7 Ensure nodev option set on /var/tmp partition (Scored)
    - mount_option_var_tmp_nodev

    ### 1.1.8 Ensure nosuid option set on /var/tmp partition (Scored)
    - mount_option_var_tmp_nosuid

    ### 1.1.9 Ensure noexec option set on /var/tmp partition (Scored)
    - mount_option_var_tmp_noexec

    ### 1.1.10 Ensure separate partition exists for /var/log (Scored)
    - partition_for_var_log

    ### 1.1.11 Ensure separate partition exists for /var/log/audit (Scored)
    - partition_for_var_log_audit

    ### 1.1.12 Ensure separate partition exists for /home (Scored)
    - partition_for_home

    ### 1.1.13 Ensure nodev option set on /home partition (Scored)
    - mount_option_home_nodev

    ### 1.1.14 Ensure nodev option set on /dev/shm partition (Scored)
    # NEEDS RULE - mount_option_dev_shm_nodev

    ### 1.1.15 Ensure nosuid option set on /dev/shm partition (Scored)
    # NEEDS RULE - mount_option_dev_shm_nosuid

    ### 1.1.16 Ensure noexec option set on /dev/shm partition (Scored)
    # NEEDS RULE - mount_option_dev_shm_noexec

    ### 1.1.17 Ensure nodev option set on removable media partitions (Not Scored)
    # NEEDS RULE - mount_option_nodev_removable_partitions

    ### 1.1.18 Ensure nosuid option set on removable media partitions (Not Scored)
    # NEEDS RULE - mount_option_nosuid_removable_partitions

    ### 1.1.19 Ensure noexec option set on removable media partitions (Not Scored)
    # NEEDS RULE - mount_option_noexec_removable_partitions

    ### 1.1.20 Ensure sticky bit is set on all world-writable directories (Scored)
    - dir_perms_world_writable_sticky_bits

    ### 1.1.21 Disable Automounting (Scored)
    # NEEDS RULE - service_autofs_disabled

    ## 1.2 Configure Software Updates

    ### 1.2.1 Ensure Red Hat Subscription Manager connection is configured (Not Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5218

    ### 1.2.2 Disable the rhnsd Daemon (Not Scored)
    # NEEDS RULE - service_rhnsd_disabled

    ## 1.3 Configure sudo

    ### 1.3.1 Ensure sudo is installed (Scored)
    # NEEDS RULE - package_sudo_installed

    ### 1.3.2 Ensure sudo commands use pty (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5220

    ### 1.3.3 Ensure sudo log file exists (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5221

    ## 1.4 Filesystem Integrity Checking

    ### 1.4.1 Ensure AIDE is installed (Scored)
    # NEEDS RULE - package_aide_installed

    ### 1.4.2 Ensure filesystem integrity is regularly checked (Scored)
    # NEEDS RULE - aide_periodic_cron_checking

    ## Secure Boot Settings

    ### 1.5.1 Ensure permissions on bootloader config are configured (Scored)
    #### chown root:root /boot/grub2/grub.cfg
    # NEEDS RULE - file_owner_grub2_cfg
    # NEEDS RULE - file_groupowner_grub2_cfg

    #### chmod og-rwx /boot/grub2/grub.cfg
    # NEEDS RULE - file_permissions_grub2_cfg

    #### chown root:root /boot/grub2/grubenv
    # NEED RULE - https://github.com/ComplianceAsCode/content/issues/5222

    #### chmod og-rwx /boot/grub2/grubenv
    # NEED RULE - https://github.com/ComplianceAsCode/content/issues/5222

    ### 1.5.2 Ensure bootloader password is set (Scored)
    # NEEDS RULE - grub2_password

    ### 1.5.3 Ensure authentication required for single user mode (Scored)
    #### ExecStart=-/usr/lib/systemd/systemd-sulogin-shell rescue
    # NEEDS RULE - require_singleuser_auth

    #### ExecStart=-/usr/lib/systemd/systemd-sulogin-shell emergency
    # NEEDS RULE - require_emergency_target_auth

    ## 1.6 Additional Process Hardening

    ### 1.6.1 Ensure core dumps are restricted (Scored)
    #### * hard core 0
    # NEEDS RULE - disable_users_coredumps

    #### fs.suid_dumpable = 0
    # NEEDS RULE - sysctl_fs_suid_dumpable

    #### ProcessSizeMax=0
    - coredump_disable_backtraces

    #### Storage=none
    - coredump_disable_storage

    ### 1.6.2 Ensure address space layout randomization (ASLR) is enabled
    - sysctl_kernel_randomize_va_space

    ## 1.7 Mandatory Access Control

    ### 1.7.1 Configure SELinux

    #### 1.6.1.1 Ensure SELinux is installed (Scored)
    # NEEDS RULE - package_libselinux_installed

    #### 1.6.1.2 Ensure the SELinux state is enforcing (Scored)
    # NEEDS RULE - var_selinux_state=enforcing
    # NEEDS RULE - selinux_state

    #### 1.6.1.3 Ensure SELinux policy is configured (Scored)
    # NEEDS RULE - var_selinux_policy_name=targeted
    # NEEDS RULE - selinux_policytype

    #### 1.6.1.4 Ensure no unconfied daemons exist (Scored)
    # NEEDS RULE - selinux_confinement_of_daemons

    ### 1.6.2 Configure AppArmor

    #### 1.6.2.1 Ensure AppArmor is not disabled in bootloader configuration (Scored)
    # NEEDS RULE

    #### 1.6.2.2 Ensure AppArmor profiles are enforcing (Scored)
    # NEEDS RULE

    ### 1.6.3 Ensure SELinux or AppArmor are installed (Scored)
    # NEEDS RULE

    ## 1.7 Warning Banners

    ### 1.7.1 Command Line Warning Baners

    #### 1.7.1.1 Ensure message of the day is configured properly (Scored)
    # NEEDS RULE - banner_etc_motd

    #### 1.7.1.2 Ensure local login warning banner is configured properly (Scored)
    # NEEDS RULE : - banner_etc_issue

    #### 1.7.1.3 Ensure remote login warning banner is configured properly (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5225

    #### 1.7.1.4 Ensure permissions on /etc/motd are configured (Scored)
    # chmod u-x,go-wx /etc/motd
    # NEEDS RULE - file_permissions_etc_motd

    #### 1.7.1.5 Ensure permissions on /etc/issue are configured (Scored)
    # chmod u-x,go-wx /etc/issue
    # NEEDS RULE - file_permissions_etc_issue

    #### 1.7.1.6 Ensure permissions on /etc/issue.net are configured (Scored)
    # Previously addressed via 'rpm_verify_permissions' rule

    ### 1.7.2 Ensure GDM login banner is configured (Scored)
    #### banner-message-enable=true
    # NEEDS RULE - dconf_gnome_banner_enabled

    #### banner-message-text='<banner message>'
    # NEEDS RULE - dconf_gnome_login_banner_text

    ## 1.8 Ensure updates, patches, and additional security software are installed (Scored)
    - security_patches_up_to_date

    # 2 Services

    ## 2.1 inetd Services

    ### 2.1.1 Ensure chargen is not installed (Scored)
    # NEEDS RULE

    ### 2.1.2 Ensure daytime services are not enabled (Scored)
    # NEEDS RULE

    ### 2.1.3 Ensured discard services are not enabled (Scored)
    # NEEDS RULE

    ### 2.1.4 Ensure echo services are not enabled (Scored)
    # NEEDS RULE

    ### 2.1.5 Ensure time services are not enabled (Scored)
    # NEEDS RULE

    ### 2.1.6 Ensure rsh server is not enabled (Scored)
    # NEEDS RULE

    ### 2.1.7 Ensure talk server is not enabled (Scored)
    # NEEDS RULE

    ### 2.1.8 Ensure telnet server is not enabled (Scored)
    # NEEDS RULE

    ### 2.1.9 Ensure tftp server is not enabled (Scored)
    # NEEDS RULE

    ### 2.1.10 Ensure xinetd is not enabled (Scored)
    # NEEDS RULE

    ### 2.1.11 Ensure openbsd-inetd is not installed (Scored)
    # NEEDS RULE

    ## 2.2 Special Purpose Services

    ### 2.2.1 Time synchronization

    #### 2.2.1.1 Ensure time synchronization is in use (Not Scored)
    # NEEDS RULE - service_chronyd_or_ntpd_enabled

    #### 2.2.1.2 Ensure ntp is configured (Scored)
    # NEEDS RULE

    #### 2.2.1.3 Ensure chrony is configured (Scored)
    # NEEDS RULE - chronyd_or_ntpd_specify_remote_server

    ### 2.2.2 Ensure X Window System is not installed (Scored)
    # NEEDS RULE - package_xorg-x11-server-common_removed

    ### 2.2.3 Ensure Avahi Server is not enabled (Scored)
    # NEEDS RULE - service_avahi-daemon_disabled

    ### 2.2.4 Ensure CUPS is not enabled (Scored)
    # NEEDS RULE - service_cups_disabled

    ### 2.2.5 Ensure DHCP Server is not enabled (Scored)
    # NEEDS RULE - service_dhcpd_disabled

    ### 2.2.6 Ensure LDAP server is not enabled (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5231

    ### 2.2.7 Ensure NFS is not enabled (Scored)
    # NEEDS RULE - service_nfs_disabled

    ### 2.2.8 Ensure DNS Server is not enabled (Scored)
    # NEEDS RULE - service_named_disabled

    ### 2.2.9 Ensure FTP Server is not enabled (Scored)
    # NEEDS RULE - service_vsftpd_disabled

    ### 2.2.10 Ensure HTTP server is not enabled (Scored)
    # NEEDS RULE - service_httpd_disabled

    ### 2.2.11 Ensure IMAP and POP3 server is not enabled (Scored)
    # NEEDS RULE - service_dovecot_disabled

    ### 2.2.12 Ensure Samba is not enabled (Scored)
    # NEEDS RULE - service_smb_disabled

    ### 2.2.13 Ensure HTTP Proxy Server is not enabled (Scored)
    # NEEDS RULE - package_squid_removed

    ### 2.2.14 Ensure SNMP Server is not enabled (Scored)
    # NEEDS RULE - service_snmpd_disabled

    ### 2.2.15 Ensure mail transfer agent is configured for
    ###        local-only mode (Scored)
    # NEEDS RULE - postfix_network_listening_disabled

    ### 2.2.16 Ensure rsync service is not enabled (Scored)
    # NEEDS RULE - service_rsyncd_disabled

    ### 2.2.17 Ensure NIS Server is not enabled (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5232

    ## 2.3 Service Clients

    ### 2.3.1 Ensure NIS Client is not installed (Scored)
    # NEEDS RULE - package_ypbind_removed

    ### 2.3.2 Ensure rsh client is not installed (Scored)
    # NEEDS RULE - package_rsh_removed

    ### 2.3.3 Ensure talk client is not installed (Scored)
    # NEEDS RULE - package_talk_removed

    ### 2.3.4 Ensure telnet client is not installed (Scored)
    # NEEDS RULE - package_telnet_removed

    ### 2.3.5 Ensure LDAP client is not installed (Scored)
    # NEEDS RULE - package_openldap-clients_removed

    # 3 Network Configuration

    ## 3.1 Network Parameters (Host Only)

    ### 3.1.1 Ensure IP forwarding is disabled (Scored)
    #### net.ipv4.ip_forward = 0
    # NEEDS RULE - sysctl_net_ipv4_ip_forward

    #### net.ipv6.conf.all.forwarding = 0
    # NEEDS RULE - sysctl_net_ipv6_conf_all_forwarding

    ### 3.1.2 Ensure packet redirect sending is disabled (Scored)
    #### net.ipv4.conf.all.send_redirects = 0
    # NEEDS RULE - sysctl_net_ipv4_conf_all_send_redirects

    #### net.ipv4.conf.default.send_redirects = 0
    # NEEDS RULE - sysctl_net_ipv4_conf_default_send_redirects

    ## 3.2 Network Parameters (Host and Router)

    ### 3.2.1 Ensure source routed packets are not accepted (Scored)
    #### net.ipv4.conf.all.accept_source_route = 0
    # NEEDS RULE - sysctl_net_ipv4_conf_all_accept_source_route

    #### net.ipv4.conf.default.accept_source_route = 0
    # NEEDS RULE - sysctl_net_ipv4_conf_default_accept_source_route

    #### net.ipv6.conf.all.accept_source_route = 0
    # NEEDS RULE # NEEDS RULE - sysctl_net_ipv6_conf_all_accept_source_route

    #### net.ipv6.conf.default.accept_source_route = 0
    # NEEDS RULE - sysctl_net_ipv6_conf_default_accept_source_route

    ### 3.2.2 Ensure ICMP redirects are not accepted (Scored)
    #### net.ipv4.conf.all.accept_redirects = 0
    # NEEDS RULE - sysctl_net_ipv4_conf_all_accept_redirects

    #### net.ipv4.conf.default.accept_redirects
    # NEEDS RULE - sysctl_net_ipv4_conf_default_accept_redirects

    #### net.ipv6.conf.all.accept_redirects = 0
    # NEEDS RULE - sysctl_net_ipv6_conf_all_accept_redirects

    #### net.ipv6.conf.defaults.accept_redirects = 0
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5234

    ### 3.2.3 Ensure secure ICMP redirects are not accepted (Scored)
    #### net.ipv4.conf.all.secure_redirects = 0
    # NEEDS RULE - sysctl_net_ipv4_conf_all_secure_redirects

    #### net.ipv4.cof.default.secure_redirects = 0
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5235

    ### 3.2.4 Ensure suspicious packets are logged (Scored)
    #### net.ipv4.conf.all.log_martians = 1
    # NEEDS RULE - sysctl_net_ipv4_conf_all_log_martians

    #### net.ipv4.conf.default.log_martians = 1
    # NEEDS RULE - sysctl_net_ipv4_conf_default_log_martians

    ### 3.2.5 Ensure broadcast ICMP requests are ignored (Scored)
    # NEEDS RULE - sysctl_net_ipv4_icmp_echo_ignore_broadcasts

    ### 3.2.6 Ensure bogus ICMP responses are ignored (Scored)
    # NEEDS RULE - sysctl_net_ipv4_icmp_ignore_bogus_error_responses

    ### 3.2.7 Ensure Reverse Path Filtering is enabled (Scored)
    #### net.ipv4.conf.all.rp_filter = 1
    # NEEDS RULE - sysctl_net_ipv4_conf_all_rp_filter

    #### net.ipv4.conf.default.rp_filter = 1
    # NEEDS RULE - sysctl_net_ipv4_conf_default_rp_filter

    ### 3.2.8 Ensure TCP SYN Cookies is enabled (Scored)
    # NEEDS RULE - sysctl_net_ipv4_tcp_syncookies

    ## 3.3 IPv6

    ### 3.3.1 Ensure IPv6 router advertisements are not accepted (Scored)
    #### net.ipv6.conf.all.accept_ra = 0
    # NEEDS RULE - sysctl_net_ipv6_conf_all_accept_ra

    #### net.ipv6.conf.default.accept_ra = 0
    # NEEDS RULE - sysctl_net_ipv6_conf_default_accept_ra

    ### 3.3.2 Ensure IPv6 redirects are not accepted (Scored)
    # NEEDS RULE

    ### 3.3.3 Ensure IPv6 is disabled (not Scored)
    # NEEDS RULE

    ## 3.4 TCP Wrappers

    ### 3.4.1 Ensure TCP Wrappers is installed (Scored)
    # NEEDS RULE

    ### 3.4.2 Ensure /etc/host.allow is configured (Scored)
    # NEEDS RULE

    ### 3.4.3 Ensure /etc/host.deny is configured (Scored)
    # NEEDS RULE

    ### 3.4.4 Ensure permissios on /etc/host.allow are configured (Scored)
    # NEEDS RULE

    ### 3.4.5 Ensure permissios on /etc/host.deny are configured (Scored)
    # NEEDS RULE

    ## 3.5 Uncommon Network Protocols

    ### 3.5.1 Ensure DCCP is disabled (Not Scored)
    # NEEDS RULE - kernel_module_dccp_disabled

    ### 3.5.2 Ensure SCTP is disabled (Not Scored)
    # NEEDS RULE - kernel_module_sctp_disabled

    ### 3.5.3 Ensure RDS is disabled (Not Scored)
    - kernel_module_rds_disabled

    ### 3.5.4 Ensure TIPC is disabled (Scored)
    - kernel_module_tipc_disabled

    ## 3.6 Firewall Configuration

    ### 3.6.1 Ensure iptables is installed
    # NEEDS RULE
    ##### iptables
    #- package_iptables_installed


    ### 3.6.2 Ensure default deny firewall policy (Scored)
    # NEEDS RULE

    ### 3.6.3 Ensure loopback traffic is configured (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5246

    ### 3.6.4 Ensure outband and established connections are configured
    #         (Not Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5247

    ##### 3.6.5 Ensure firewall rules exist for all open ports (Scored)
    # NEEDS RULE - https://github.com/ComplianceAsCode/content/issues/5255

    ## 3.7 Ensure wireless interfaces are disabled (Scored)
    # NEEDS RULE - wireless_disable_interfaces

    # 4 Logging and Auditing

    ## 4.1 Configure System Accounting (auditd)

    ### 4.1.1 Configure Data Retention

    #### 4.1.1.1 Ensure audit log storage size is configured (Scored)
    - auditd_data_retention_max_log_file

    #### 4.1.1.2 Ensure system is disabled when audit logs are full (Scored)
    - var_auditd_space_left_action=email
    - auditd_data_retention_space_left_action

    ##### action_mail_acct = root
    - var_auditd_action_mail_acct=root
    - auditd_data_retention_action_mail_acct

    ##### admin_space_left_action = halt
    - var_auditd_admin_space_left_action=halt
    - auditd_data_retention_admin_space_left_action

    #### 4.1.1.3 Ensure audit logs are not automatically deleted (Scored)
    - auditd_data_retention_max_log_file_action

    #### 4.1.2 Ensure auditd service is enabled (Scored)
    - service_auditd_enabled

    #### 4.1.3 Ensure auditing for processes that start prior to audit
    ####         is enabled (Scored)
    # NEEDS RULE - grub2_audit_argument

    ### 4.1.4 Ensure events that modify date and time information
    ###       are collected (Scored)
    #### adjtimex
    - audit_rules_time_adjtimex

    ### 4.1.5 Ensure events that modify user/group information are
    ###        collected (Scored)

    ### 4.1.6 Ensure events that modify the system's network
    ###       enironment are collected (Scored)
    - audit_rules_networkconfig_modification

    ### 4.1.7 Ensure events that modify the system's Mandatory
    ###       Access Control are collected (Scored)
    #### -w /etc/selinux/ -p wa
    - audit_rules_mac_modification

    ### 4.1.8 Ensure login and logout events are collected (Scored)
    # NEEDS RULE - audit_rules_login_events_faillock
    # NEEDS RULE - audit_rules_login_events_lastlog

    ### 4.1.9 Ensure session initiation information is collected (Scored)
    - audit_rules_session_events

    ### 4.1.10 Ensure discretionary access control permission modification
    ###        events are collected (Scored)

    ### 4.1.11 Ensure unsuccessful unauthorized file access attempts are
    ###        collected (Scored)

    ### 4.1.12 Ensure use of privileged commands is collected (Scored)

    ### 4.1.13 Ensure successful file system mounts are collected (Scored)

    ### 4.1.14 Ensure file deletion events by users are collected
    ###        (Scored)

    ### 4.1.15 Ensure changes to system administration scope
    ###        (sudoers) is collected (Scored)
    - audit_rules_sysadmin_actions

    ### 4.1.16 Ensure system administrator actions (sudolog) are
    ###        collected (Scored)

    ### 4.1.17 Ensure kernel module loading and unloading is collected
    ###        (Scored)

    ### 4.1.18 Ensure the audit configuration is immutable (Scored)

    ## 4.2 Configure Logging

    ### 4.2.1 Configure rsyslog

    #### 4.2.1.1 Ensure rsyslog Service is enabled (Scored)

    #### 4.2.1.2 Ensure logging is configured (Not Scored)

    #### 4.2.1.3 Ensure rsyslog default file permissions configured (Scored)


    #### 4.2.1.4 Ensure rsyslog is configured to send logs to a remote
    ####         log host (Scored)


    #### 4.2.1.5 Ensure remote rsyslog messages are only accepted on
    ####         designated log hosts (Not Scored)

    ### 4.2.2 Configure syslog-ng

    #### 4.2.2.1 Ensure syslog-ng is enabled (Scored)

    #### 4.2.2.2 Ensure logging is configured (Not Scored)

    #### 4.2.2.3 Ensure syslog-ng default file permissions configured
    #            (Scored)

    #### 4.2.2.4 Ensure syslog-ng is configured to send logs to a remote
    #            log host (Not Scored)

    #### 4.2.2.5 Ensure remote syslog-ng message are only accepted on
    #            designated hosts (Not Scored)

    ### 4.2.3 Ensure syslog or syslog-ng is installed (Scored)

    ### 4.2.4 Ensure permissions on all logfiles are configured (Scored)

    ## 4.3 Ensure logrotate is conifgured (Not Scored)


    # 5 Access, Authentication and Authorization

    ## 5.1 Configure cron


    ### 5.1.1 Ensure cron daemon is enabled (Scored)


    ### 5.1.2 Ensure permissions on /etc/crontab are configured (Scored)
    # chown root:root /etc/crontab
    # NEEDS RULE - file_owner_crontab
    # NEEDS RULE - file_groupowner_crontab
    # chmod og-rwx /etc/crontab
    # NEEDS RULE - file_permissions_crontab

    ### 5.1.3 Ensure permissions on /etc/cron.hourly are configured (Scored)
    # chown root:root /etc/cron.hourly
    # NEEDS RULE - file_owner_cron_hourly
    # NEEDS RULE - file_groupowner_cron_hourly
    # chmod og-rwx /etc/cron.hourly
    # NEEDS RULE - file_permissions_cron_hourly

    ### 5.1.4 Ensure permissions on /etc/cron.daily are configured (Scored)
    # chown root:root /etc/cron.daily
    # NEEDS RULE - file_owner_cron_daily
    # NEEDS RULE - file_groupowner_cron_daily
    # chmod og-rwx /etc/cron.daily
    # NEEDS RULE - file_permissions_cron_daily

    ### 5.1.5 Ensure permissions on /etc/cron.weekly are configured (Scored)
    # chown root:root /etc/cron.weekly
    # NEEDS RULE - file_owner_cron_weekly
    # NEEDS RULE - file_groupowner_cron_weekly
    # chmod og-rwx /etc/cron.weekly
    # NEEDS RULE - file_permissions_cron_weekly

    ### 5.1.6 Ensure permissions on /etc/cron.monthly are configured (Scored)
    # chown root:root /etc/cron.monthly
    # NEEDS RULE - file_owner_cron_monthly
    # NEEDS RULE - file_groupowner_cron_monthly
    # chmod og-rwx /etc/cron.monthly
    # NEEDS RULE - file_permissions_cron_monthly

    ### 5.1.7 Ensure permissions on /etc/cron.d are configured (Scored)
    # chown root:root /etc/cron.d
    # NEEDS RULE - file_owner_cron_d
    # NEEDS RULE - file_groupowner_cron_d
    # chmod og-rwx /etc/cron.d
    # NEEDS RULE - file_permissions_cron_d

    ### 5.1.8 Ensure at/cron is restricted to authorized users (Scored)


    ## 5.2 SSH Server Configuration

    ### 5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured (Scored)
    # chown root:root /etc/ssh/sshd_config
    # NEEDS RULE - file_owner_sshd_config
    # NEEDS RULE - file_groupowner_sshd_config

    # chmod og-rwx /etc/ssh/sshd_config
    # NEEDS RULE - file_permissions_sshd_config

    ### 5.2.2 Ensure SSH protocol is set to 2 (Scored)

    ### 5.2.2 Ensure SSH access is limited (Scored)

    ### 5.2.3 Ensure SSH LogLevel is set to INFO (Scored)
    - sshd_set_loglevel_info

    ### 5.2.4 Ensure SSH X11 forwarding is diabled (Scored)

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

    ### 5.2.11 Ensure only approved MAC algorithm are used (Scored)

    ### 5.2.12 Ensure SSH Idle Timeout Interval is configured (Scored)
    # ClientAliveInterval 300
    - sshd_idle_timeout_value=5_minutes
    - sshd_set_idle_timeout

    # ClientAliveCountMax 0
    - sshd_set_keepalive

    ### 5.2.13 Ensure SSH LoginGraceTime is set to one minute
    ###        or less (Scored)

    ### 5.2.14 Ensure SSH access is limited (Scored)

    ### 5.2.15 Ensure SSH warning banner is configured (Scored)
    - sshd_enable_warning_banner

    ## 5.3 Configure PAM

    ### 5.3.1 Ensure password creation requirements are configured (Scored)


    ### 5.3.2 Ensure lockout for failed password attempts is
    ###       configured (Scored)


    ### 5.3.3 Ensure password reuse is limited (Scored)


    ### 5.3.4 Ensure password hashing algorithm is SHA-512 (Scored)


    ## 5.4 User Accounts and Environment

    ### 5.4.1 Set Shadow Password Suite Parameters

    #### 5.4.1 Ensure password expiration is 365 days or less (Scored)


    #### 5.4.1.2 Ensure minimum days between password changes is 7
    ####         or more (Scored)


    #### 5.4.1.3 Ensure password expiration warning days is
    ####         7 or more (Scored)


    #### 5.4.1.4 Ensure inactive password lock is 30 days or less (Scored)


    #### 5.4.1.5 Ensure all users last password change date is
    ####         in the past (Scored)


    ### 5.4.2 Ensure system accounts are non-login (Scored)

    ### 5.4.3 Ensure default group for the root account is
    ###       GID 0 (Scored)

    ### 5.4.4 Ensure default user mask is 027 or more restrictive (Scored)


    ### 5.4.5 Ensure default user shell timeout is 900 seconds
    ###       or less (Scored)


    ## 5.5 Ensure root login is restricted to system console (Not Scored)


    ## 5.6 Ensure access to the su command is restricted (Scored)

    # System Maintenance

    ## 6.1 System File Permissions

    ### 6.1.1 Audit system file permissions (Not Scored)
    # NEEDS RULE - rpm_verify_permissions
    # NEEDS RULE - rpm_verify_ownership

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
    # NEEDS RULE - no_files_unowned_by_user

    ### 6.1.12 Ensure no ungrouped files or directories exist (Scored)
    # NEEDS RULE - file_permissions_ungroupowned

    ### 6.1.13 Audit SUID executables (Not Scored)
    # NEEDS RULE - file_permissions_unauthorized_suid

    ### 6.1.14 Audit SGID executables (Not Scored)
    # NEEDS RULE - file_permissions_unauthorized_sgid

    ## 6.2 User and Group Settings

    ### 6.2.1 Ensure password fields are not empty (Scored)

    ### 6.2.2 Ensure no legacy "+" entries exist in /etc/passwd (Scored)
    # NEEDS RULE - no_legacy_plus_entries_etc_passwd

    ## 6.2.3 Ensure no legacy "+" entries exist in /etc/shadow (Scored)
    # NEEDS RULE - no_legacy_plus_entries_etc_shadow

    ###6.2.4 Ensure no legacy "+" entries exist in /etc/group (Scored)
    # NEEDS RULE - no_legacy_plus_entries_etc_group

    ### 6.2.5 Ensure root is the only UID 0 account (Scored)

    ### 6.2.6 Ensure root PATH Integrity (Scored)

    ### 6.2.7 Ensure all users' home directory exist (Scored)

    ### 6.2.8 Ensure users home directory permissions are 750 or more
    # restrictive (Scored)

    ### 6.2.9 Ensure users own their own home directories (Scored)

    ### 6.2.10 Ensure users dot files are not group or world writable
    # (Scored)

    ### 6.2.11 Ensure no users have .forward files (Scored)

    ### 6.2.12 Ensure no users have .netrc files (Scored)

    ### 6.2.13 Ensure users .netrc files are not group or world accessible
    # (Scored)

    ### 6.2.14 Ensure no users have .rhosts files (Scored)

    ### 6.2.15 Ensure all groups in /etc/passwd exists in /etc/group (Scored)

    ### 6.2.16 Ensure no duplicate UIDs exist (Scored)

    ### 6.2.17 Ensure no duplicate GIDs exists (Scored)

    ### 6.2.18 Ensure no duplicate user names exists (Scored)

    ### 6.2.19 Ensure no duplicate group names exists (Scored)

    ### 6.2.20 Ensure shadow group is empty (Scored)
