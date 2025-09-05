documentation_complete: true

title: 'CIS Ubuntu 22.04 Level 1 Server Benchmark'

description: |-
    This baseline aligns to the Center for Internet Security
    Ubuntu 22.04 LTS Benchmark, v1.0.0, released 08-30-2022.

selections:
    # 1 Initial Setup #
    ## 1.1 Filesystem Configuration ##
    ### 1.1.1 Disable unused filesystems ###
    #### 1.1.1.1 Ensure mounting of cramfs filesystems is disabled (Automated)
    - kernel_module_cramfs_disabled

    #### 1.1.1.2 Ensure mounting of squashfs filesystems is disabled (Automated)
    # Skip due to being Level 2

    #### 1.1.1.3 Ensure mounting of udf filesystems is disabled (Automated)
    # Skip due to being Level 2

    ### 1.1.2 Configure /tmp ###
    #### 1.1.2.1 Ensure /tmp is a separate partition (Automated)
    - partition_for_tmp

    #### 1.1.2.2 Ensure nodev option set on /tmp partition (Automated)
    - mount_option_tmp_nodev

    #### 1.1.2.3 Ensure noexec option set on /tmp partition (Automated)
    - mount_option_tmp_noexec

    #### 1.1.2.4 Ensure nosuid option set on /tmp partition (Automated)
    - mount_option_tmp_nosuid

    ### 1.1.3 Configure /var
    #### 1.1.3.1 Ensure separate partition exists for /var (Automated)
    # Skip due to being Level 2

    #### 1.1.3.2 Ensure nodev option set on /var partition (Automated)
    - mount_option_var_nodev

    #### 1.1.3.3 Ensure nosuid option set on /var partition (Automated)
    - mount_option_var_nosuid

    ### 1.1.4 Configure /var/tmp
    #### 1.1.4.1 Ensure separate partition exists for /var/tmp (Automated)
    # Skip due to being Level 2

    ### 1.1.4.2 Ensure noexec option set on /var/tmp partition (Automated)
    - mount_option_var_tmp_noexec

    ### 1.1.4.3 Ensure nosuid option set on /var/tmp partition (Automated)
    - mount_option_var_tmp_nosuid

    #### 1.1.4.4 Ensure nodev option set on /var/tmp partition (Automated)
    - mount_option_var_tmp_nodev

    ### 1.1.5 Configure /var/log ###
    #### 1.1.5.1 Ensure separate partition exists for /var/log (Automated)
    # Skip due to being Level 2

    #### 1.1.5.2 Ensure nodev option set on /var/log partition (Automated)
    - mount_option_var_log_nodev

    #### 1.1.5.3 Ensure noexec option set on /var/log partition (Automated)
    - mount_option_var_log_noexec

    #### 1.1.5.4 Ensure nosuid option set on /var/log partition (Automated)
    - mount_option_var_log_nosuid

    ### 1.1.6 Configure /var/log/audit ###
    #### 1.1.6.1 Ensure separate partition exists for /var/log/audit (Automated)
    # Skip due to being Level 2

    #### 1.1.6.2 Ensure noexec option set on /var/log/audit partition (Automated)
    - mount_option_var_log_audit_noexec

    #### 1.1.6.3 Ensure nodev option set on /var/log/audit partition (Automated)
    - mount_option_var_log_audit_nodev

    #### 1.1.6.4 Ensure nosuid option set on /var/log/audit partition (Automated)
    - mount_option_var_log_audit_nosuid

    ### 1.1.7 Configure /home ###
    #### 1.1.7.1 Ensure separate partition exists for /home (Automated)
    # Skip due to being Level 2

    #### 1.1.7.2 Ensure nodev option set on /home partition (Automated)
    - mount_option_home_nodev

    #### 1.1.7.2 Ensure nosuid option set on /home partition (Automated)
    - mount_option_home_nosuid

    ### 1.1.8 Configure /dev/shm ###
    #### 1.1.8.1 Ensure nodev option set on /dev/shm partition (Automated)
    - mount_option_dev_shm_nodev

    #### 1.1.8.2 Ensure noexec option set on /dev/shm partition (Automated)
    - mount_option_dev_shm_noexec

    #### 1.1.8.3 Ensure nosuid option set on /dev/shm partition (Automated)
    - mount_option_dev_shm_nosuid

    ### 1.1.9 Disable Automounting (Automated)
    - service_autofs_disabled

    ### 1.1.10 Disable USB Storage (Automated)
    - kernel_module_usb-storage_disabled

    ## 1.2 Configure Software Updates ##
    ### 1.2.1 Ensure package manager repositories are configured (Manual)
    # Skip due to being a manual test

    ### 1.2.2 Ensure GPG keys are configured (Manual)
    # Skip due to being a manual test

    ## 1.3 Filesystem Integrity Checking ##
    ### 1.3.1 Ensure AIDE is installed (Automated)
    - package_aide_installed
    - aide_build_database

    ### 1.3.2 Ensure filesystem integrity is regularly checked (Automated)
    - aide_periodic_cron_checking

    ## 1.4 Secure Boot Settings ##
    ### 1.4.1 Ensure bootloader password is set (Automated)
    - grub2_password
    - grub2_uefi_password

    ### 1.4.2 Ensure permissions on bootloader config are configured (Automated)
    - file_owner_grub2_cfg
    - file_permissions_grub2_cfg

    ### 1.4.3 Ensure authentication required for single user mode (Automated)
    # NEEDS RULE

    ## 1.5 Additional Process Hardening ##
    ### 1.5.1 Ensure address space layout randomization (ASLR) is enabled (Automated)
    - sysctl_kernel_randomize_va_space

    ### 1.5.2 Ensure prelink is disabled (Automated)
    - package_prelink_removed

    ### 1.5.3 Ensure Automatic Error Reporting is not enabled (Automated)
    - service_apport_disabled

    ### 1.5.4 Ensure core dumps are restricted (Automated)
    - disable_users_coredumps
    - sysctl_fs_suid_dumpable

    ## 1.6 Mandatory Access Control ##
    ### 1.6.1 Configure AppArmor ###
    #### 1.6.1.1 Ensure AppArmor is installed (Automated)
    - package_apparmor_installed

    #### 1.6.1.2 Ensure AppArmor is enabled in the bootloader configuration (Automated)
    - grub2_enable_apparmor

    #### 1.6.1.3 Ensure all AppArmor Profiles are in enforce or complain mode (Automated)
    # NEEDS RULE

    #### 1.6.1.4 Ensure all AppArmor Profiles are enforcing (Automated)
    # Skip due to being Level 2

    ## 1.7 Command Line Warning Banners ##
    ### 1.7.1 Ensure message of the day is configured properly (Automated)
    # NEEDS RULE

    ### 1.7.2 Ensure local login warning banner is configured properly (Automated)
    - login_banner_text=cis_default
    - banner_etc_issue

    ### 1.7.3 Ensure remote login warning banner is configured properly (Automated)
    - banner_etc_issue_net

    ### 1.7.4 Ensure permissions on /etc/motd are configured (Automated)
    - file_permissions_etc_motd
    - file_owner_etc_motd
    - file_groupowner_etc_motd

    ### 1.7.5 Ensure permissions on /etc/issue are configured (Automated)
    - file_permissions_etc_issue
    - file_owner_etc_issue
    - file_groupowner_etc_issue

    ### 1.7.6 Ensure permissions on /etc/issue.net are configured (Automated)
    - file_permissions_etc_issue_net
    - file_owner_etc_issue_net
    - file_groupowner_etc_issue_net

    ## 1.8 GNOME Display Manager ##
    ### 1.8.1 Ensure GNOME Display Manager is removed (Automated)
    # Skip due to being Level 2

    ### 1.8.2 Ensure GDM login banner is configured (Automated)
    - login_banner_text=cis_default
    - dconf_gnome_banner_enabled
    - dconf_gnome_login_banner_text

    ### 1.8.3 Ensure GDM disable-user-list option is enabled (Automated)
    - dconf_gnome_disable_user_list

    ### 1.8.4 Ensure GDM screen locks when the user is idle (Automated)
    - dconf_gnome_screensaver_lock_enabled

    ### 1.8.5 Ensure GDM screen locks cannot be overridden (Automated)
    - dconf_gnome_screensaver_lock_delay

    ### 1.8.6 Ensure GDM automatic mounting of removable media is disabled (Automated)
    - dconf_gnome_disable_automount
    - dconf_gnome_disable_automount_open

    ### 1.8.7 Ensure GDM disabling automatic mounting of removable media is not overridden (Automated)
    # SAME AS ABOVE ??

    ### 1.8.8 Ensure GDM autorun-never is enabled (Automated)
    - dconf_gnome_disable_autorun

    ### 1.8.9 Ensure GDM autorun-never is not overridden (Automated)
    # SAME AS ABOVE ??

    ### 1.8.10 Ensure XDCMP is not enabled (Automated)
    - gnome_gdm_disable_xdmcp

    ## 1.9 Ensure updates, patches, and additional security software are installed (Manual)
    # Skip due to being a manual test

    # 2. Services #
    ## 2.1 Configure Time Synchronization ##
    ### 2.1.1 Ensure time synchronization is in use ###
    #### 2.1.1.1 Ensure a single time synchronization is in use (Automated)
    - package_chrony_installed

    ### 2.1.2 Configure chrony ###
    #### 2.1.2.1 Ensure chrony is configured with autorized timeserver (Manual)
    # Skip due to being a manual test

    #### 2.1.2.2 Ensure chrony is running as user _chrony (Automated)
    - chronyd_run_as_chrony_user

    #### 2.1.2.3 Ensure chrony is enabled and running (Automated)
    # NEEDS RULE

    ### 2.1.3 Configure systemd-timesyncd ###
    #### 2.1.3.1 Ensure systemd-timesyncd configured with autorized timeserver (Manual)
    # Skip due to being a manual test

    #### 2.1.3.2 Ensure systemd-timesyncd is enabled and running (Automated)
    # - service_timesyncd_enabled

    ### 2.1.4 Configure ntp ###
    #### 2.1.4.1 Ensure ntp access control is configured (Automated)
    #- ntpd_configure_restrictions

    #### 2.1.4.2 Ensure ntp is configured with authorized timeserver (Manual)
    # Skip due to being a manual test

    #### 2.1.4.3 Ensure ntp is running as user ntp (Automated)
    #- ntpd_run_as_ntp_user

    #### 2.1.4.4 Ensure ntp is enabled and running (Automated)
    #- package_ntp_installed
    #- package_chrony_removed
    #- service_ntp_enabled

    ## 2.2 Special Purpose Services ##
    ### 2.2.1 Ensure X Window System is not installed (Automated)
    - package_xorg-x11-server-common_removed

    ### 2.2.2 Ensure Avahi Server is not installed (Automated)
    - service_avahi-daemon_disabled

    ### 2.2.3 Ensure CUPS is not installed (Automated)
    - service_cups_disabled
    - package_cups_removed

    ### 2.2.4 Ensure DHCP Server is not installed (Automated)
    - package_dhcp_removed

    ### 2.2.5 Ensure LDAP server is not installed (Automated)
    - package_openldap-servers_removed

    ### 2.2.6 Ensure NFS is not installed (Automated)
    # NEEDS RULE

    ### 2.2.7 Ensure DNS Server is not installed (Automated)
    - package_bind_removed

    ### 2.2.8 Ensure FTP Server is not installed (Automated)
    - package_vsftpd_removed

    ### 2.2.9 Ensure HTTP server is not installed (Automated)
    - package_httpd_removed

    ### 2.2.10 Ensure IMAP and POP3 server are not installed (Automated)
    - package_dovecot_removed

    ### 2.2.11 Ensure Samba is not installed (Automated)
    - package_samba_removed

    ### 2.2.12 Ensure HTTP Proxy Server is not installed (Automated)
    - package_squid_removed

    ### 2.2.13 Ensure SNMP Server is not installed (Automated)
    - package_net-snmp_removed

    ### 2.2.14 Ensure NIS Server is not installed (Automated)
    - package_nis_removed

    ### 2.2.15 Ensure mail transfer agent is configured for local-only mode (Automated)
    - var_postfix_inet_interfaces=loopback-only
    - postfix_network_listening_disabled

    ### 2.2.16 Ensure rsync service is not installed (Automated)
    - package_rsync_removed

    ## 2.3 Service Clients ##
    ### 2.3.1 Ensure NIS Client is not installed (Automated)
    # (Duplicate of above as client and server are in the same binary)
    # - package_nis_removed

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
    ### 3.1.1 Ensure system is checked to determine if IPv6 is enabled (Manual)
    # Skip due to being a manual test

    ### 3.1.2 Ensure wireless interfaces are disabled (Automated)
    - wireless_disable_interfaces

    ## 3.2 Network Parameters (Host Only) ##
    ### 3.2.1 Ensure packet redirect sending is disabled (Automated)
    - sysctl_net_ipv4_conf_all_send_redirects
    - sysctl_net_ipv4_conf_default_send_redirects

    ### 3.2.2 Ensure IP forwarding is disabled (Automated)
    - sysctl_net_ipv4_ip_forward
    - sysctl_net_ipv6_conf_all_forwarding

    ## 3.3 Network Parameters (Host and Router) ##
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

    ## 3.5 Firewall Configuration ##
    ### 3.5.1 Configure UncomplicatedFirewall ###
    #### 3.5.1.1 Ensure ufw is installed (Automated)
    - package_ufw_installed

    #### 3.5.1.2 Ensure iptables-persistent is not installed with ufw (Automated)
    # NEEDS RULE

    #### 3.5.1.3 Ensure ufw service is enabled (Automated)
    - service_ufw_enabled

    #### 3.5.1.4 Ensure ufw loopback traffic is configured (Automated)
    # NEEDS RULE

    #### 3.5.1.5 Ensure ufw outbound connections are configured (Manual)
    # Skip due to being a manual test

    #### 3.5.1.6 Ensure ufw firewall rules exist for all open ports (Automated)
    # NEEDS RULE

    #### 3.5.1.7 Ensure ufw default deny firewall policy (Automated)
    # NEEDS RULE

    ### 3.5.2 Configure nftables ###
    #### 3.5.2.1 Ensure nftables is installed (Automated)
    - package_nftables_installed

    #### 3.5.2.2 Ensure ufw is uninstalled or disabled with nftables (Automated)
    # NEEDS RULE

    #### 3.5.2.3 Ensure iptables are flushed with nftables (Manual)
    # Skip due to being a manual test

    #### 3.5.2.4 Ensure a nftables table exists (Automated)
    # NEEDS RULE

    #### 3.5.2.5 Ensure nftables base chains exist (Automated)
    # NEEDS RULE

    #### 3.5.2.6 Ensure nftables loopback traffic is configured (Automated)
    # NEEDS RULE

    #### 3.5.2.7 Ensure nftables outbound and established connections are configured (Manual)
    # Skip due to being a manual test

    #### 3.5.2.8 Ensure nftables default deny firewall policy (Automated)
    # NEEDS RULE

    #### 3.5.2.9 Ensure nftables service is enabled (Automated)
    # NEEDS RULE

    #### 3.5.2.10 Ensure nftables rules are permanent (Automated)
    # NEEDS RULE

    ### 3.5.3 Configure iptables ###
    #### 3.5.3.1 Configure iptables software ####
    ##### 3.5.3.1.1 Ensure iptables packages are installed (Automated)
    - package_iptables_installed

    ###### 3.5.3.1.2 Ensure nftables is not installed with iptables (Automated)
    - service_nftables_disabled
    - packages_nftables_removed

    ###### 3.5.3.1.3 Ensure ufw is uninstalled or disabled with iptables (Automated)
    # NEEDS RULE

    #### 3.5.3.2 Configure IPv4 iptables ####
    ##### 3.5.3.2.1 Ensure iptables default deny firewall policy (Automated)
    # NEEDS RULE

    ##### 3.5.3.2.2 Ensure iptables loopback traffic is configured (Automated)
    # NEEDS RULE

    ##### 3.5.3.2.3 Ensure iptables outbound and established connections are configured (Manual)
    # Skip due to being a manual test

    ##### 3.5.3.2.4 Ensure iptables firewall rules exist for all open ports (Automated)
    # not manual anymore

    #### 3.5.3.3 Configure IPv6 ip6tables ####
    ##### 3.5.3.3.1 Ensure ip6tables default deny firewall policy (Automated)
    # NEEDS RULE

    # 3.5.3.3.2 Ensure ip6tables loopback traffic is configured (Automated)
    # NEEDS RULE

    # 3.5.3.3.3 Ensure ip6tables outbound and established connections are configured (Manual)
    # Skip due to being a manual test

    # 3.5.3.3.4 Ensure ip6tables firewall rules exist for all open ports (Automated)
    # not manual anymore
    # NEEDS RULE

    # 4 Logging and Auditing #
    ## 4.1 Configure System Accounting (auditd) ##
    ### 4.1.1 Ensure auditing is enabled ###
    #### 4.1.1.1 Ensure auditd is installed (Automated)
    # Skip due to being Level 2

    #### 4.1.1.2 Ensure auditd service is enabled and active (Automated)
    # Skip due to being Level 2

    #### 4.1.1.3 Ensure auditing for processes that start prior to auditd is enabled (Automated)
    # Skip due to being Level 2

    #### 4.1.1.4 Ensure audit_backlog_limit is sufficient (Automated)
    # Skip due to being Level 2

    ### 4.1.2 Configure Data Retention ###
    #### 4.1.2.1 Ensure audit log storage size is configured (Automated)
    # Skip due to being Level 2

    #### 4.1.2.2 Ensure audit logs are not automatically deleted (Automated)
    # Skip due to being Level 2

    #### 4.1.2.3 Ensure system is disabled when audit logs are full (Automated)
    # Skip due to being Level 2

    ### 4.1.3 Configure auditd rules ###
    #### 4.1.3.1 Ensure changes to system administration scope (sudoers) is collected (Automated)
    # Skip due to being Level 2

    #### 4.1.3.2 Ensure actions as another user are always logged (Automated)
    # Skip due to being Level 2

    #### 4.1.3.3 Ensure events that modify the sudo log file are collected (Automated)
    # Skip due to being Level 2

    #### 4.1.3.4 Ensure events that modify date and time information are collected (Automated)
    # Skip due to being Level 2

    #### 4.1.3.5 Ensure events that modify the system's network environment are collected (Automated)
    # Skip due to being Level 2

    #### 4.1.3.6 Ensure use of privileged commands are collected (Automated)
    # Skip due to being Level 2

    #### 4.1.3.7 Ensure unsuccessful file access attempts are collected (Automated)
    # Skip due to being Level 2

    #### 4.1.3.8 Ensure events that modify user/group information are collected (Automated)
    # Skip due to being Level 2

    #### 4.1.3.9 Ensure discretionary access control permission modification events are collected (Automated)
    # Skip due to being Level 2

    #### 4.1.3.10 Ensure successful file system mounts are collected (Automated)
    # Skip due to being Level 2

    #### 4.1.3.11 Ensure session initiation information is collected (Automated)
    # Skip due to being Level 2

    #### 4.1.3.12 Ensure login and logout events are collected (Automated)
    # Skip due to being Level 2

    #### 4.1.3.13 Ensure file deletion events by users are collected (Automated)
    # Skip due to being Level 2

    #### 4.1.3.14 Ensure events that modify the system's Mandatory Access Controls are collected (Automated)
    # Skip due to being Level 2

    #### 4.1.3.15 Ensure successful and unsuccessful attempts to use the chcon command are recorded (Automated)
    # Skip due to being Level 2

    #### 4.1.3.16 Ensure successful and unsuccessful attempts to use the setfacl command are recorded (Automated)
    # Skip due to being Level 2

    #### 4.1.3.17 Ensure successful and unsuccessful attempts to use the chacl command are recorded (Automated)
    # Skip due to being Level 2

    #### 4.1.3.18 Ensure successful and unsuccessful attempts to use the usermod command are recorded (Automated)
    # Skip due to being Level 2

    #### 4.1.3.19 Ensure kernel module loading unloading and modification is collected (Automated)
    # Skip due to being Level 2

    #### 4.1.3.20 Ensure the audit configuration is immutable (Automated)
    # Skip due to being Level 2

    #### 4.1.3.21 Ensure the running and on disk configuration is the same (Manual)
    # Skip due to being a manual test

    ### 4.1.4 Configure auditd file access ###
    #### 4.1.4.1 Ensure audit log files are mode 0640 or less permissive (Automated)
    - file_permissions_var_log_audit

    #### 4.1.4.2 Ensure only authorized users own audit log files (Automated)
    - file_ownership_var_log_audit_stig

    #### 4.1.4.3 Ensure only authorized groups are assigned ownership of audit log files (Automated)
    - file_group_ownership_var_log_audit

    #### 4.1.4.4 Ensure the audit log directory is 0750 or more restrictive (Automated)
    - directory_permissions_var_log_audit

    #### 4.1.4.5 Ensure audit configuration files are 640 or more restrictive (Automated)
    - file_permissions_etc_audit_rulesd
    - file_permissions_etc_audit_auditd

    #### 4.1.4.6 Ensure audit configuration files are owned by root (Automated)
    - file_ownership_audit_configuration

    #### 4.1.4.7 Ensure audit configuration files belong to group root (Automated)
    - file_groupownership_audit_configuration

    #### 4.1.4.8 Ensure audit tools are 755 or more restrictive (Automated)
    - file_permissions_audit_binaries

    #### 4.1.4.9 Ensure audit tools are owned by root (Automated)
    - file_ownership_audit_binaries

    #### 4.1.4.10 Ensure audit tools belong to group root (Automated)
    - file_groupownership_audit_binaries

    #### 4.1.4.11 Ensure cryptographic mechanisms are used to protect the integrity of audit tools (Automated)
    - aide_check_audit_tools

    ## 4.2 Configure Logging ##
    ### 4.2.1 Configure journald ###
    #### 4.2.1.1 Ensure journald is configured to send logs to a remote log host ####
    ##### 4.2.1.1.1 Ensure systemd-journal-remote is installed (Automated)
    # NEEDS RULE

    ##### 4.2.1.1.2 Ensure systemd-journal-remote is configured (Manual)
    # Skip due to being a manual test

    ##### 4.2.1.1.3 Ensure systemd-journal-remote is enabled (Manual)
    # Skip due to being a manual test

    ##### 4.2.1.1.4 Ensure journald is not configured to receive logs from a remote client (Automated)
    # NEEDS RULE

    #### 4.2.1.2 Ensure journald service is enabled (Automated)
    - service_systemd-journald_enabled

    #### 4.2.1.3 Ensure journald is configured to compress large log files (Automated)
    - journald_compress

    #### 4.2.1.4 Ensure journald is configured to write logfiles to persistent disk (Automated)
    - journald_storage

    #### 4.2.1.5 Ensure journald is not configured to send logs to rsyslog (Manual)
    # Skip due to being a manual test

    #### 4.2.1.6 Ensure journald log rotation is configured per site policy (Manual)
    # Skip due to being a manual test

    #### 4.2.1.7 Ensure journald default file permissions configured (Manual)
    # Skip due to being a manual test

    ### 4.2.2 Configure rsyslog ###
    #### 4.2.2.1 Ensure rsyslog is installed (Automated)
    - package_rsyslog_installed

    #### 4.2.2.2 Ensure rsyslog service is enabled (Automated)
    - service_rsyslog_enabled

    #### 4.2.2.3 Ensure journald is configured to send logs to rsyslog (Manual)
    # Skip due to being a manual test

    #### 4.2.2.4 Ensure rsyslog default file permissions are configured (Automated)
    # not manual anymore
    # NEEDS RULE

    #### 4.2.2.5 Ensure logging is configured (Manual)
    # Skip due to being a manual test

    #### 4.2.2.6 Ensure rsyslog is configured to send logs to a remote log host (Automated)
    - rsyslog_remote_loghost

    #### 4.2.2.7 Ensure rsyslog is not configured to receive logs from a remote client (Automated)
    # NEEDS RULE

    ### 4.2.3 Ensure all logfiles have appropriate permissions and ownership (Automated)
    # NEEDS RULE

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
    - file_cron_deny_not_exist
    - file_permissions_cron_allow
    - file_owner_cron_allow
    - file_groupowner_cron_allow

    ### 5.1.9 Ensure at is restricted to authorized users (Automated)
    - file_at_deny_not_exist
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

    ### 5.2.4 Ensure SSH access is limited (Automated)
    # NEEDS RULE

    ### 5.2.5 Ensure SSH LogLevel is appropriate (Automated)
    - sshd_set_loglevel_info

    ### 5.2.6 Ensure SSH PAM is enabled (Automated)
    - sshd_enable_pam

    ### 5.2.7 Ensure SSH root login is disabled (Automated)
    - sshd_disable_root_login

    ### 5.2.8 Ensure SSH HostbasedAuthentication is disabled (Automated)
    - disable_host_auth

    ### 5.2.9 Ensure SSH PermitEmptyPasswords is disabled (Automated)
    - sshd_disable_empty_passwords

    ### 5.2.10 Ensure SSH PermitUserEnvironment is disabled (Automated)
    - sshd_do_not_permit_user_env

    ### 5.2.11 Ensure SSH IgnoreRhosts is enabled (Automated)
    - sshd_disable_rhosts

    ### 5.2.12 Ensure SSH X11 forwarding is disabled (Automated)
    # Skip due to being Level 2

    ### 5.2.13 Ensure only strong Ciphers are used (Automated)
    - sshd_approved_ciphers=cis_ubuntu
    - sshd_use_approved_ciphers

    ### 5.2.14 Ensure only strong MAC algorithms are used (Automated)
    - sshd_approved_macs=cis_ubuntu
    - sshd_use_approved_macs

    ### 5.2.15 Ensure only strong Key Exchange algorithms are used (Automated)
    # NEEDS RULE

    ### 5.2.16 Ensure SSH AllowTcpForwarding is disabled (Automated)
    # Skip due to being Level 2

    ### 5.2.17 Ensure SSH warning banner is configured (Automated)
    - sshd_enable_warning_banner_net

    ### 5.2.18 Ensure SSH MaxAuthTries is set to 4 or less (Automated)
    - sshd_max_auth_tries_value=4
    - sshd_set_max_auth_tries

    ### 5.2.19 Ensure SSH MaxStartups is configured (Automated)
    - var_sshd_set_maxstartups=10:30:60
    - sshd_set_maxstartups

    ### 5.2.20 Ensure SSH MaxSessions is set to 10 or less (Automated)
    - var_sshd_max_sessions=10
    - sshd_set_max_sessions

    ### 5.2.21 Ensure SSH LoginGraceTime is set to one minute or less (Automated)
    - var_sshd_set_login_grace_time=60
    - sshd_set_login_grace_time

    ### 5.2.22 Ensure SSH Idle Timeout Interval is configured (Automated)
    - sshd_idle_timeout_value=5_minutes
    - sshd_set_idle_timeout
    - var_sshd_set_keepalive=3
    - sshd_set_keepalive

    ## 5.3 Configure privilege escalation
    ### 5.3.1 Ensure sudo is installed (Automated)
    - package_sudo_installed

    ### 5.3.2 Ensure sudo commands use pty (Automated)
    - sudo_add_use_pty

    ### 5.3.3 Ensure sudo log file exists (Automated)
    - sudo_custom_logfile

    ### 5.3.4 Ensure users must provide password for privilege escalation (Automated)
    # Skip due to being Level 2

    ### 5.3.5 Ensure re-authentication for privilege escalation is not disabled globally (Automated)
    - sudo_remove_no_authenticate

    ### 5.3.6 Ensure sudo authentication timeout is configured correctly (Automated)
    - var_sudo_timestamp_timeout=15_minutes
    - sudo_require_reauthentication

    ### 5.3.7 Ensure access to the su command is restricted (Automated)
    # NEEDS RULE

    ## 5.4 Configure PAM ##
    ### 5.4.1 Ensure password creation requirements are configured (Automated)
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

    ### 5.4.2 Ensure lockout for failed password attempts is configured (Automated)
    - var_accounts_passwords_pam_faillock_deny=4
    - accounts_passwords_pam_faillock_deny
    - var_accounts_passwords_pam_faillock_fail_interval=900
    - accounts_passwords_pam_faillock_interval
    - var_accounts_passwords_pam_faillock_unlock_time=600
    - accounts_passwords_pam_faillock_unlock_time

    ### 5.4.3 Ensure password reuse is limited (Automated)
    - var_password_pam_remember=5
    - accounts_password_pam_pwhistory_remember

    ### 5.4.4 Ensure password hashing algorithm is up to date with the latest standards (Automated)
    # NEEDS RULE

    ### 5.4.5 Ensure all current passwords uses the configured hashing algorithm (Manual)
    # Skip due to being a manual test

    ## 5.5 User Accounts and Environment ##
    ### 5.5.1 Set Shadow Password Suite Parameters ###
    #### 5.5.1.1 Ensure minimum days between password changes is configured (Automated)
    - var_accounts_minimum_age_login_defs=1
    - accounts_minimum_age_login_defs
    - accounts_password_set_min_life_existing

    #### 5.5.1.2 Ensure password expiration is 365 days or less (Automated)
    - var_accounts_maximum_age_login_defs=365
    - accounts_maximum_age_login_defs
    - accounts_password_set_max_life_existing

    #### 5.5.1.3 Ensure password expiration warning days is 7 or more (Automated)
    - var_accounts_password_warn_age_login_defs=7
    - accounts_password_warn_age_login_defs

    #### 5.5.1.4 Ensure inactive password lock is 30 days or less (Automated)
    - var_account_disable_post_pw_expiration=30
    - account_disable_post_pw_expiration

    #### 5.5.1.5 Ensure all users last password change date is in the past (Automated)
    # NEEDS RULE

    ### 5.5.2 Ensure system accounts are secured (Automated)
    - no_shelllogin_for_systemaccounts

    ### 5.5.3 Ensure default group for the root account is GID 0 (Automated)
    - accounts_root_gid_zero

    ### 5.5.4 Ensure default user umask is 027 or more restrictive (Automated)
    - var_accounts_user_umask=027
    - accounts_umask_etc_login_defs
    - accounts_umask_etc_profile
    - accounts_umask_etc_bashrc
    - accounts_umask_interactive_users

    ### 5.5.5 Ensure default user shell timeout is 900 seconds or less (Automated)
    - var_accounts_tmout=15_min
    - accounts_tmout

    # 6 System Maintenance #
    ## 6.1 System File Permissions ##
    ### 6.1.1 Ensure permissions on /etc/passwd are configured (Automated)
    - file_permissions_etc_passwd
    - file_owner_etc_passwd
    - file_groupowner_etc_passwd

    ### 6.1.2 Ensure permissions on /etc/passwd- are configured (Automated)
    - file_permissions_backup_etc_passwd
    - file_owner_backup_etc_passwd
    - file_groupowner_backup_etc_passwd

    ### 6.1.3 Ensure permissions on /etc/group are configured (Automated)
    - file_permissions_etc_group
    - file_owner_etc_group
    - file_groupowner_etc_group

    ### 6.1.4 Ensure permissions on /etc/group- are configured (Automated)
    - file_permissions_backup_etc_group
    - file_owner_backup_etc_group
    - file_groupowner_backup_etc_group

    ### 6.1.5 Ensure permissions on /etc/shadow are configured (Automated)
    - file_permissions_etc_shadow
    - file_owner_etc_shadow
    - file_groupowner_etc_shadow

    ### 6.1.6 Ensure permissions on /etc/shadow- are configured (Automated)
    - file_permissions_backup_etc_shadow
    - file_owner_backup_etc_shadow
    - file_groupowner_backup_etc_shadow

    ### 6.1.7 Ensure permissions on /etc/gshadow are configured (Automated)
    - file_permissions_etc_gshadow
    - file_owner_etc_gshadow
    - file_groupowner_etc_gshadow

    ### 6.1.8 Ensure permissions on /etc/gshadow- are configured (Automated)
    - file_permissions_backup_etc_gshadow
    - file_owner_backup_etc_gshadow
    - file_groupowner_backup_etc_gshadow

    ### 6.1.9 Ensure no world writable files exist (Automated)
    - file_permissions_unauthorized_world_writable

    ### 6.1.10 Ensure no unowned files or directories exist (Automated)
    - no_files_unowned_by_user

    ### 6.1.11 Ensure no ungrouped files or directories exist (Automated)
    - file_permissions_ungroupowned

    ### 6.1.12 Audit SUID executables (Manual)
    # Skip due to being a manual test

    ### 6.1.13 Audit SGID executables (Manual)
    # Skip due to being a manual test

    ## 6.2 Local User and Group Settings ##
    ### 6.2.1 Ensure accounts in /etc/passwd use shadowed passwords (Automated)
    - accounts_password_all_shadowed

    ### 6.2.2 Ensure /etc/shadow password fields are not empty (Automated)
    - no_empty_passwords_etc_shadow

    ### 6.2.3 Ensure all groups in /etc/passwd exist in /etc/group (Automated)
    - gid_passwd_group_same

    ### 6.2.4 Ensure shadow group is empty (Automated)
    - ensure_shadow_group_empty

    ### 6.2.5 Ensure no duplicate UIDs exist (Automated)
    - account_unique_id

    ### 6.2.6 Ensure no duplicate GIDs exist (Automated)
    - group_unique_id

    ### 6.2.7 Ensure no duplicate user names exist (Automated)
    - account_unique_name

    ### 6.2.8 Ensure no duplicate group names exist (Automated)
    - group_unique_name

    ### 6.2.9 Ensure root PATH Integrity (Automated)
    - accounts_root_path_dirs_no_write
    - root_path_no_dot

    ### 6.2.10 Ensure root is the only UID 0 account (Automated)
    - accounts_no_uid_except_zero

    ### 6.2.11 Ensure local interactive user home directories exist (Automated)
    - accounts_user_interactive_home_directory_exists

    ### 6.2.12 Ensure local interactive users own their home directories (Automated)
    - file_ownership_home_directories
    - file_groupownership_home_directories

    ### 6.2.13 Ensure users' home directories permissions are 750 or more restrictive (Automated)
    - file_permissions_home_directories

    ### 6.2.14 Ensure no local interactive user has .netrc files (Automated)
    - no_netrc_files

    ### 6.2.15 Ensure no local interactive user has .forward files (Automated)
    # - no_forward_files

    ### 6.2.16 Ensure no users have .rhosts files (Automated)
    - no_rsh_trust_files

    ### 6.2.17 Ensure local interactive user dot files are not group or world writable (Automated)
    - accounts_user_dot_no_world_writable_programs
    - accounts_user_dot_group_ownership
    - accounts_user_dot_user_ownership
