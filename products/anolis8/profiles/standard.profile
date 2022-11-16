documentation_complete: true

title: 'Standard System Security Profile for Anolis OS 8'

description: |-
    This profile contains rules to ensure standard security baseline
    of a Anolis OS 8 system.

selections:
    # 1 access-and-control
    ## 1.1-ensure-cron-daemon-is-enabled
    ### Level 1
    - service_crond_enabled

    ## 1.2-ensure-permissions-on-etc-crontab-are-configured
    ### Level 1
    - file_groupowner_crontab
    - file_owner_crontab
    - file_permissions_crontab

    ## 1.3-ensure-permissions-on-etc-cron.hourly-are-configured
    ### Level 1
    - file_groupowner_cron_hourly
    - file_owner_cron_hourly
    - file_permissions_cron_hourly

    ## 1.4-ensure-permissions-on-etc-cron.daily-are-configured
    ### Level 1
    - file_groupowner_cron_daily
    - file_owner_cron_daily
    - file_permissions_cron_daily

    ## 1.5-ensure-permissions-on-etc-cron.weekly-are-configured
    ### Level 1
    - file_groupowner_cron_weekly
    - file_owner_cron_weekly
    - file_permissions_cron_weekly

    ## 1.6-ensure-permissions-on-etc-cron.monthly-are-configured
    ### Level 1
    - file_groupowner_cron_monthly
    - file_owner_cron_monthly
    - file_permissions_cron_monthly

    ## 1.7-ensure-permissions-on-etc-cron.d-are-configured
    ### Level 1
    - file_groupowner_cron_d
    - file_owner_cron_d
    - file_permissions_cron_d

    ## 1.8-ensure-at-cron-is-restricted-to-authorized-users
    ### Level 1
    - file_groupowner_cron_allow
    - file_owner_cron_allow
    - file_cron_deny_not_exist
    - file_groupowner_at_allow
    - file_owner_at_allow
    - file_at_deny_not_exist
    - file_permissions_at_allow
    - file_permissions_cron_allow

    ## 1.9-ensure-permissions-on-etc-ssh-sshd_config-are-configured
    ### Level 1
    - file_groupowner_sshd_config
    - file_owner_sshd_config
    - file_permissions_sshd_config

    ## 1.10-ensure-ssh-access-is-limited
    ### Level 2
    # Needs rule

    ## 1.11-ensure-permissions-on-ssh-private-host-key-files-are-configured
    ### Level 1
    - file_permissions_sshd_private_key

    ## 1.12-ensure-permissions-on-ssh-public-host-key-files-are-configured
    ### Level 1
    - file_permissions_sshd_pub_key

    ## 1.13-ensure-ssh-loglevel-is-appropriate
    ### Level 1
    - sshd_set_loglevel_verbose
    # or
    - sshd_set_loglevel_info

    ## 1.14-ensure-ssh-maxauthtries-is-set-to-4-or-less
    ### Level 1
    - sshd_max_auth_tries_value=4
    - sshd_set_max_auth_tries

    ## 1.15-ensure-ssh-ignorerhosts-is-enabled
    ### Level 1
    - sshd_disable_rhosts

    ## 1.16-ensure-ssh-hostbasedauthentication-is-disabled
    ### Level 1
    - disable_host_auth

    ## 1.17-ensure-ssh-root-login-is-disabled
    ### Level 1
    - sshd_disable_root_login

    ## 1.18-ensure-ssh-permitemptypasswords-is-disabled
    ### Level 1
    - sshd_disable_empty_passwords

    ## 1.19-ensure-ssh-permituserenvironment-is-disabled
    ### Level 1
    - sshd_do_not_permit_user_env

    ## 1.20-ensure-ssh-idle-timeout-interval-is-configured
    ### Level 1
    - sshd_idle_timeout_value=15_minutes
    - sshd_set_idle_timeout
    - sshd_set_keepalive
    - var_sshd_set_keepalive=0

    ## 1.21-ensure-ssh-logingracetime-is-set-to-one-minute-or-less
    ### Level 1
    - sshd_set_login_grace_time
    - var_sshd_set_login_grace_time=60

    ## 1.22-ensure-ssh-warning-banner-is-configured
    ### Level 1
    - sshd_enable_warning_banner

    ## 1.23-ensure-ssh-pam-is-enabled
    ### Level 1
    - sshd_enable_pam

    ## 1.24-ensure-ssh-maxstartups-is-configured
    ### Level 1
    - sshd_set_maxstartups
    - var_sshd_set_maxstartups=10:30:60

    ## 1.25-ensure-ssh-maxsessions-is-set-to-10-or-less
    ### Level 1
    - sshd_set_max_sessions
    - var_sshd_max_sessions=10

    ## 1.26-ensure-system-wide-crypto-policy-is-not-over-ridden
    ### Level 1
    # Needs rule

    ## 1.27-ensure-password-creation-requirements-are-configured
    ### Level 1
    - accounts_password_pam_minclass
    - accounts_password_pam_minlen
    - accounts_password_pam_retry
    - var_password_pam_minclass=4
    - var_password_pam_minlen=14

    ## 1.28-ensure-lockout-for-failed-password-attempts-is-configured
    ### Level 1
    - locking_out_password_attempts

    ## 1.29-ensure-password-reuse-is-limited
    ### Level 1
    - accounts_password_pam_pwhistory_remember_password_auth
    - accounts_password_pam_pwhistory_remember_system_auth
    - var_password_pam_remember_control_flag=required
    - var_password_pam_remember=5

    ## 1.30-ensure-password-hashing-algorithm-is-sha-512
    ### Level 1
    - set_password_hashing_algorithm_systemauth

    ## 1.31-ensure-password-expiration-is-365-days-or-less
    ### Level 1
    - accounts_maximum_age_login_defs
    - var_accounts_maximum_age_login_defs=365
    - accounts_password_set_max_life_existing

    ## 1.32-ensure-minimum-days-between-password-changes-is-7-or-more
    ### Level 1
    - accounts_minimum_age_login_defs
    - var_accounts_minimum_age_login_defs=7
    - accounts_password_set_min_life_existing

    ## 1.33-ensure-password-expiration-warning-days-is-7-or-more
    ### Level 1
    - accounts_password_warn_age_login_defs
    - var_accounts_password_warn_age_login_defs=7

    ## 1.34-ensure-inactive-password-lock-is-30-days-or-less
    ### Level 1
    - account_disable_post_pw_expiration
    - var_account_disable_post_pw_expiration=30

    ## 1.35-ensure-all-users-last-password-change-date-is-in-the-past
    ### Level 2
    # Needs rule

    ## 1.36-ensure-system-accounts-are-secured
    ### Level 1
    - no_shelllogin_for_systemaccounts

    ## 1.37-ensure-default-user-shell-timeout-is-900-seconds-or-less
    ### Level 1
    - accounts_tmout
    - var_accounts_tmout=15_min

    ## 1.38-ensure-default-group-for-the-root-account-is-gid-0
    ### Level 1
    - accounts_root_gid_zero

    ## 1.39-ensure-default-user-umask-is-027-or-more-restrictive
    ### Level 1
    - accounts_umask_etc_bashrc
    - accounts_umask_etc_login_defs
    - accounts_umask_etc_profile
    - var_accounts_user_umask=027

    ## 1.40-ensure-access-to-the-su-command-is-restricted
    ### Level 1
    - use_pam_wheel_for_su

    ## 1.41-ensure-ssh-server-use-protocol_2
    ### Level 1
    - sshd_allow_only_protocol2

    ## 2.1-ensure-audit-log-files-are-not-read-or-write-accessible-by-unauthorized-users
    ### Level 1
    # Needs rule

    ## 2.2-ensure-only-authorized-users-own-audit-log-files
    ### Level 1
    # Needs rule

    ## 2.3-ensure-only-authorized-groups-ownership-of-audit-log-files
    ### Level 1
    # Needs rule

    ## 2.4-ensure-the-audit-log-directory-is-0750-or-more-restrictive
    ### Level 1
    # Needs rule

    ## 2.5-ensure-audit-configuration-files-are-0640-or-more-restrictive
    ### Level 1
    # Needs rule

    ## 2.6-ensure-only-authorized-accounts-own-the-audit-configuration-files
    ### Level 1
    # Needs rule

    ## 2.7-ensure-only-authorized-groups-own-the-audit-configuration-files
    ### Level 1
    # Needs rule

    ## 2.8-ensure-audit-tools-are-mode-of-0755-or-more-restrictive
    ### Level 1
    # Needs rule

    ## 2.9-ensure-audit-tools-are-owned-by-root
    ### Level 1
    # Needs rule

    ## 2.10-ensure-audit-tools-are-group-owned-by-root
    ### Level 1
    # Needs rule

    ## 2.11-ensure-cryptographic-mechanisms-are-used-to-protect-the-integrity-of-audit-tools
    ### Level 1
    # Needs rule

    ## 2.12-ensure-rsyslog-is-installed
    ### Level 1
    - package_rsyslog_installed

    ## 2.13-ensure-rsyslog-service-is-enabled
    ### Level 1
    - service_rsyslog_enabled

    ## 2.14-ensure-rsyslog-default-file-permissions-configured
    ### Level 1
    # Needs rule

    ## 2.15-ensure-rsyslog-is-configured-to-send-logs-to-a-remote-log-host
    ### Level 2
    - rsyslog_remote_loghost

    ## 2.16-ensure-journald-is-configured-to-send-logs-to-rsyslog
    ### Level 1
    - journald_forward_to_syslog

    ## 2.17-ensure-journald-is-configured-to-compress-large-log-files
    ### Level 1
    - journald_compress

    ## 2.18-ensure-journald-is-configured-to-write-logfiles-to-persistent-disk
    ### Level 1
    - journald_storage

    ## 2.19-ensure-audit-is-installed
    ### Level 1
    - package_audit_installed

    ## 2.20-ensure-audit-service-is-enabled
    ### Level 3
    - service_auditd_enabled

    ## 3.1-disable-http-server
    ### Level 1
    - service_httpd_disabled

    ## 3.2-disable-ftp-server
    ### Level 1
    - service_vsftpd_disabled

    ## 3.3-disable-dns-server
    ### Level 1
    - service_named_disabled

    ## 3.4-disable-nfs
    ### Level 1
    - service_nfs_disabled

    ## 3.5-disable-rpc
    ### Level 1
    - service_rpcbind_disabled

    ## 3.6-disable-ldap-server
    ### Level 1
    - service_slapd_disabled

    ## 3.7-disable-dhcp-server
    ### Level 1
    - service_dhcpd_disabled

    ## 3.8-disable-cups
    ### Level 1
    - service_cups_disabled

    ## 3.9-disable-nis-server
    ### Level 1
    - service_ypserv_disabled

    ## 3.10-disable-rsync-server
    ### Level 1
    - service_rsyncd_disabled

    ## 3.11-disable-avahi-server
    ### Level 1
    - service_avahi-daemon_disabled

    ## 3.12-disable-snmp-server
    ### Level 1
    - service_snmpd_disabled

    ## 3.13-disable-http-proxy-server
    ### Level 1
    - service_squid_disabled

    ## 3.14-disable-samba
    ### Level 1
    - service_smb_disabled

    ## 3.15-disable-imap-and-pop3-server
    ### Level 1
    - service_dovecot_disabled

    ## 3.16-disable-smtp-protocol
    ### Level 1
    # Needs rule

    ## 3.17-disable-telnet-port-23
    ### Level 1
    # Needs rule

    ## 4.1-ensure-message-of-the-day-is-configured-properly
    ### Level 1
    - banner_etc_motd
    - login_banner_text=cis_banners

    ## 4.2-ensure-local-login-warning-banner-is-configured-properly
    ### Level 1
    - banner_etc_issue
    - login_banner_text=cis_banners

    ## 4.3-ensure-remote-login-warning-banner-is-configured-properly
    ### Level 1
    # Needs rule

    ## 4.4-ensure-permissions-on-etc-motd-are-configured
    ### Level 1
    - file_groupowner_etc_motd
    - file_owner_etc_motd
    - file_permissions_etc_motd

    ## 4.5-ensure-permissions-on-etc-issue-are-configured
    ### Level 1
    - file_groupowner_etc_issue
    - file_owner_etc_issue
    - file_permissions_etc_issue

    ## 4.6-ensure-permissions-on-etc-issue.net-are-configured
    ### Level 1
    # Needs rule

    ## 4.7-ensure-gpgcheck-is-globally-activated
    ### Level 1
    - ensure_gpgcheck_globally_activated

    ## 4.8-ensure-aide-is-installed
    ### Level 1
    - package_aide_installed

    ## 4.9-ensure-filesystem-integrity-is-regularly-checked
    ### Level 1
    - aide_periodic_cron_checking

    ## 4.10-ensure-bootloader-password-is-set
    ### Level 2
    - grub2_password

    ## 4.11-ensure-permissions-on-bootloader-config-are-configured
    ### Level 1
    #- file_groupowner_efi_grub2_cfg
    - file_groupowner_grub2_cfg
    #- file_owner_efi_grub2_cfg
    - file_owner_grub2_cfg
    #- file_permissions_efi_grub2_cfg
    - file_permissions_grub2_cfg

    ## 4.12-ensure-authentication-required-for-single-user-mode
    ### Level 1
    - require_singleuser_auth
    - require_emergency_target_auth

    ## 4.13-ensure-core-dumps-are-restricted
    ### Level 1
    - disable_users_coredumps
    - sysctl_fs_suid_dumpable
    - coredump_disable_backtraces
    - coredump_disable_storage

    ## 4.14-ensure-address-space-layout-randomization-(ASLR)-is-enabled
    ### Level 1
    - sysctl_kernel_randomize_va_space

    ## 4.15-ensure-system-wide-crypto-policy-is-not-legacy
    ### Level 1
    - configure_crypto_policy
    - var_system_crypto_policy=default_policy

    ## 4.16-ensure-sticky-bit-is-set-on-all-world-writable-directories
    ### Level 1
    - dir_perms_world_writable_sticky_bits

    ## 4.17-ensure-permissions-on-etc-passwd-are-configured
    ### Level 1
    - file_permissions_etc_passwd

    ## 4.18-ensure-permissions-on-etc-shadow-are-configured
    ### Level 1
    - file_owner_etc_shadow
    - file_groupowner_etc_shadow
    - file_permissions_etc_shadow

    ## 4.19-ensure-permissions-on-etc-group-are-configured
    ### Level 1
    - file_groupowner_etc_group
    - file_owner_etc_group
    - file_permissions_etc_group

    ## 4.20-ensure-permissions-on-etc-gshadow-are-configured
    ### Level 1
    - file_groupowner_etc_gshadow
    - file_owner_etc_gshadow
    - file_permissions_etc_gshadow

    ## 4.21-ensure-permissions-on-etc-passwd--are-configured
    ### Level 1
    - file_groupowner_backup_etc_passwd
    - file_owner_backup_etc_passwd
    - file_permissions_backup_etc_passwd

    ## 4.22-ensure-permissions-on-etc-shadow--are-configured
    ### Level 1
    - file_groupowner_backup_etc_shadow
    - file_owner_backup_etc_shadow
    - file_permissions_backup_etc_shadow

    ## 4.23-ensure-permissions-on-etc-group--are-configured
    ### Level 1
    - file_groupowner_backup_etc_group
    - file_owner_backup_etc_group
    - file_permissions_backup_etc_group

    ## 4.24-ensure-permissions-on-etc-gshadow--are-configured
    ### Level 1
    - file_groupowner_backup_etc_gshadow
    - file_owner_backup_etc_gshadow
    - file_permissions_backup_etc_gshadow

    ## 4.25-ensure-no-world-writable-files-exist
    ### Level 2
    - file_permissions_unauthorized_world_writable

    ## 4.26-ensure-no-unowned-files-or-directories-exist
    ### Level 2
    # Needs rule

    ## 4.27-ensure-no-ungrouped-files-or-directories-exist
    ### Level 2
    - file_permissions_ungroupowned

    ## 4.28-ensure-no-password-fields-are-not-empty
    ### Level 2
    # Needs rule

    ## 4.29-ensure-root-path-integrity
    ### Level 2
    - accounts_root_path_dirs_no_write
    - root_path_no_dot

    ## 4.30-ensure-root-is-the-only-uid-0-account
    ### Level 2
    - accounts_no_uid_except_zero

    ## 4.31-ensure-users-home-directories-permissions-are-750-or-more-restrictive
    ### Level 1
    # Needs rule

    ## 4.32-ensure-users-own-their-home-directories
    ### Level 1
    - file_ownership_home_directories
    - file_groupownership_home_directories

    ## 4.33-ensure-users-dot-files-are-not-group-or-world-writable
    ### Level 1
    # Needs rule

    ## 4.34-ensure-no-users-have-.forward-files
    ### Level 1
    # Needs rule

    ## 4.35-ensure-no-users-have-.netrc-files
    ### Level 1
    - no_netrc_files

    ## 4.36-ensure-users-.netrc-files-are-not-group-or-world-accessible
    ### Level 1
    # Needs rule

    ## 4.37-ensure-no-users-have-.rhosts-files
    ### Level 1
    - no_rsh_trust_files

    ## 4.38-ensure-all-groups-in-etc-passwd-exist-in-etc-group
    ### Level 2
    # Needs rule

    ## 4.39-ensure-no-duplicate-uids-exist
    ### Level 2
    - account_unique_id

    ## 4.40-ensure-no-duplicate-gids-exist
    ### Level 2
    - group_unique_id

    ## 4.41-ensure-no-duplicate-user-names-exist
    ### Level 2
    # Needs rule

    ## 4.42-ensure-no-duplicate-group-names-exist
    ### Level 2
    - group_unique_name

    ## 4.43-ensure-all-users-home-directories-exist
    ### Level 1
    # Needs rule

    ## 4.44-ensure-sctp-is-disabled
    ### Level 1
    - kernel_module_sctp_disabled

    ## 4.45-ensure-dccp-is-disabled
    ### Level 1
    - kernel_module_dccp_disabled

    ## 4.46-ensure-wireless-interfaces-are-disabled
    ### Level 1
    - wireless_disable_interfaces

    ## 4.47-ensure-ip-forwarding-is-disabled
    ### Level 1
    - sysctl_net_ipv4_ip_forward
    - sysctl_net_ipv6_conf_all_forwarding
    - sysctl_net_ipv6_conf_all_forwarding_value=disabled

    ## 4.48-ensure-packet-redirect-sending-is-disabled
    ### Level 1
    - sysctl_net_ipv4_conf_all_send_redirects
    - sysctl_net_ipv4_conf_default_send_redirects

    ## 4.49-ensure-source-routed-packets-are-not-accepted
    ### Level 1
    - sysctl_net_ipv4_conf_all_accept_source_route
    - sysctl_net_ipv4_conf_all_accept_source_route_value=disabled
    - sysctl_net_ipv4_conf_default_accept_source_route
    - sysctl_net_ipv4_conf_default_accept_source_route_value=disabled
    - sysctl_net_ipv6_conf_all_accept_source_route
    - sysctl_net_ipv6_conf_all_accept_source_route_value=disabled
    - sysctl_net_ipv6_conf_default_accept_source_route
    - sysctl_net_ipv6_conf_default_accept_source_route_value=disabled

    ## 4.50-ensure-icmp-redirects-are-not-accepted
    ### Level 1
    - sysctl_net_ipv4_conf_all_accept_redirects
    - sysctl_net_ipv4_conf_all_accept_redirects_value=disabled
    - sysctl_net_ipv4_conf_default_accept_redirects
    - sysctl_net_ipv4_conf_default_accept_redirects_value=disabled
    - sysctl_net_ipv6_conf_all_accept_redirects
    - sysctl_net_ipv6_conf_all_accept_redirects_value=disabled
    - sysctl_net_ipv6_conf_default_accept_redirects
    - sysctl_net_ipv6_conf_default_accept_redirects_value=disabled

    ## 4.51-ensure-secure-icmp-redirects-are-not-accepted
    ### Level 1
    - sysctl_net_ipv4_conf_all_secure_redirects
    - sysctl_net_ipv4_conf_all_secure_redirects_value=disabled
    - sysctl_net_ipv4_conf_default_secure_redirects
    - sysctl_net_ipv4_conf_default_secure_redirects_value=disabled

    ## 4.52-ensure-suspicious-packets-are-logged
    ### Level 1
    - sysctl_net_ipv4_conf_all_log_martians
    - sysctl_net_ipv4_conf_all_log_martians_value=enabled
    - sysctl_net_ipv4_conf_default_log_martians
    - sysctl_net_ipv4_conf_default_log_martians_value=enabled

    ## 4.53-ensure-broadcast-icmp-requests-are-ignored
    ### Level 1
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts_value=enabled

    ## 4.54-ensure-bogus-icmp-responses-are-ignored
    ### Level 1
    - sysctl_net_ipv4_icmp_ignore_bogus_error_responses
    - sysctl_net_ipv4_icmp_ignore_bogus_error_responses_value=enabled

    ## 4.55-ensure-reverse-path-filtering-is-enabled
    ### Level 1
    - sysctl_net_ipv4_conf_all_rp_filter
    - sysctl_net_ipv4_conf_all_rp_filter_value=enabled
    - sysctl_net_ipv4_conf_default_rp_filter
    - sysctl_net_ipv4_conf_default_rp_filter_value=enabled

    ## 4.56-ensure-tcp-syn-cookies-is-enabled
    ### Level 1
    - sysctl_net_ipv4_tcp_syncookies
    - sysctl_net_ipv4_tcp_syncookies_value=enabled

    ## 4.57-ensure-ipv6-router-advertisements-are-not-accepted
    ### Level 1
    - sysctl_net_ipv6_conf_all_accept_ra
    - sysctl_net_ipv6_conf_all_accept_ra_value=disabled
    - sysctl_net_ipv6_conf_default_accept_ra
    - sysctl_net_ipv6_conf_default_accept_ra_value=disabled

    ## 4.58-ensure-a-firewall-package-is-installed
    ### Level 1
    - package_firewalld_installed

    ## 4.59-ensure-firewalld-service-is-enabled-and-running
    ### Level 1
    - service_firewalld_enabled

    ## 4.60-ensure-iptables-is-not-enabled
    ### Level 1
    # Needs rule

    ## 4.61-ensure-nftables-is-not-enabled
    ### Level 1
    # Needs rule

    ## 4.62-ensure-nftables-service-is-enabled
    ### Level 1
    # Needs rule

    ## 4.63-ensure-iptables-packages-are-installed
    ### Level 1
    - package_iptables_installed

    ## 4.64-ensure-nftables-is-not-installed
    ### Level 1
    # Needs rule

    ## 4.65-ensure-firewalld-is-not-installed-or-stopped-and-masked
    ### Level 1
    # Needs rule

    ## 4.66-ensure-system-histsize-as-100-or-other
    ### Level 1
    # Needs rule

    ## 4.67-ensure-system-histfilesize-100
    ### Level 1
    # Needs rule

    ## 5.1-ensure-selinux-is-installed
    ### Level 1
    # Needs rule

    ## 5.2-ensure-selinux-policy-is-configured
    ### Level 3
    # Needs rule

    ## 5.3-ensure-the-selinux-mode-is-enabled
    ### Level 3
    # Needs rule

    ## 5.4-ensure-the-selinux-mode-is-enforcing
    ### Level 3
    # Needs rule

    ## 5.5-ensure-no-unconfined-services-exist
    ### Level 4
    # Needs rule

    ## 5.6-use-selinux-for-separation-of-powers-user-created
    ### Level 4
    # Needs rule

    ## 5.7-use-selinux-for-separation-of-powers-system-administrator-login-permission-configuration
    ### Level 4
    # Needs rule