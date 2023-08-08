documentation_complete: true

metadata:
    version: V1R4
    SMEs:
        - esampson

reference: 

title: 'Hardening for Public Cloud Image of SUSE Linux Enterprise Server (SLES) for SAP Applications 15'

description: |-
    This profile contains configuration rules to be used to harden the images
    of SUSE Linux Enterprise Server (SLES) for SAP Applications 15 including
    all Service Packs, for Public Cloud providers, currently AWS, Microsoft
    Azure, and Google Cloud.

extends: pcs-hardening

selections:
    # Include some rules and var defs from CIS level 1
    # CIS L1 var defs
    - var_sudo_logfile=var_log_sudo_log
    - var_apparmor_mode=complain
    - motd_banner_text=cis_banners
    - login_banner_text=cis_banners
    - remote_login_banner_text=cis_banners
    - login_banner_text=cis_default
    - var_multiple_time_servers=suse
    - var_multiple_time_pools=suse
    - var_postfix_inet_interfaces=loopback-only
    - sysctl_net_ipv6_conf_all_forwarding_value=disabled
    - sysctl_net_ipv4_conf_all_accept_source_route_value=disabled
    - sysctl_net_ipv4_conf_default_accept_source_route_value=disabled
    - sysctl_net_ipv6_conf_all_accept_source_route_value=disabled
    - sysctl_net_ipv6_conf_default_accept_source_route_value=disabled
    - sysctl_net_ipv4_conf_all_accept_redirects_value=disabled
    - sysctl_net_ipv4_conf_default_accept_redirects_value=disabled
    - sysctl_net_ipv6_conf_all_accept_redirects_value=disabled
    - sysctl_net_ipv6_conf_default_accept_redirects_value=disabled
    - sysctl_net_ipv4_conf_all_secure_redirects_value=disabled
    - sysctl_net_ipv4_conf_default_secure_redirects_value=disabled
    - sysctl_net_ipv4_conf_all_log_martians_value=enabled
    - sysctl_net_ipv4_conf_default_log_martians_value=enabled
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts_value=enabled
    - sysctl_net_ipv4_icmp_ignore_bogus_error_responses_value=enabled
    - sysctl_net_ipv4_conf_all_rp_filter_value=enabled
    - sysctl_net_ipv4_conf_default_rp_filter_value=enabled
    - sysctl_net_ipv4_tcp_syncookies_value=enabled
    - sysctl_net_ipv6_conf_all_accept_ra_value=disabled
    - sysctl_net_ipv6_conf_default_accept_ra_value=disabled
    - var_nftables_family=inet
    - var_nftables_table=filter
    - var_nftables_table=filter
    - var_nftables_family=inet
    - var_nftables_base_chain_names=chain_names
    - var_nftables_base_chain_types=chain_types
    - var_nftables_base_chain_hooks=chain_hooks
    - var_nftables_base_chain_priorities=chain_priorities
    - var_nftables_base_chain_policies=chain_policies
    - var_nftables_master_config_file=sysconfig
    - var_nftables_master_config_file=sysconfig
    - var_auditd_max_log_file=6
    - var_auditd_max_log_file_action=keep_logs
    - var_auditd_space_left_action=email
    - var_auditd_action_mail_acct=root
    - var_auditd_admin_space_left_action=halt
    - sshd_max_auth_tries_value=4
    - sshd_approved_ciphers=cis_sle15
    - sshd_approved_macs=cis_sle15
    - sshd_strong_kex=cis_sle15
    - sshd_idle_timeout_value=5_minutes
    - var_sshd_set_keepalive=0
    - var_sshd_set_login_grace_time=60
    - var_sshd_set_maxstartups=10:30:60
    - var_sshd_max_sessions=10
    - var_password_pam_dcredit=1
    - var_password_pam_ucredit=1
    - var_password_pam_lcredit=1
    - var_password_pam_ocredit=1
    - var_password_pam_minlen=14
    - var_password_pam_retry=3
    - var_password_pam_tally2=5
    - var_accounts_passwords_pam_tally2_unlock_time=1800
    - var_password_pam_remember=5
    - var_accounts_maximum_age_login_defs=365
    - var_accounts_minimum_age_login_defs=1
    - var_accounts_password_warn_age_login_defs=7
    - var_account_disable_post_pw_expiration=30
    - var_accounts_tmout=15_min
    - var_accounts_user_umask=027
    - var_pam_wheel_group_for_su=cis
    # CIS L1 Rules
    - install_smartcard_packages
    - package_aide_installed
    - package_audit-audispd-plugins_installed
    - package_audit_installed
    - package_chrony_installed
    - package_iptables_installed
    - package_rsyslog_installed
    - banner_etc_issue_net
    - account_disable_post_pw_expiration
    - accounts_set_post_pw_existing
    - accounts_users_home_files_permissions
    - file_permissions_home_directories
    - rsyslog_files_permissions
    - journald_forward_to_syslog
    - rsyslog_remote_loghost
    - sysctl_net_ipv6_conf_all_accept_ra
    - sysctl_net_ipv6_conf_all_accept_source_route
    - sysctl_net_ipv6_conf_all_forwarding
    - sysctl_net_ipv6_conf_default_accept_ra
    - sysctl_net_ipv6_conf_default_accept_source_route
    - sysctl_net_ipv4_conf_all_log_martians
    - sysctl_net_ipv4_conf_all_rp_filter
    - sysctl_net_ipv4_conf_all_secure_redirects
    - sysctl_net_ipv4_conf_default_log_martians
    - sysctl_net_ipv4_conf_default_rp_filter
    - sysctl_net_ipv4_conf_default_secure_redirects
    - sysctl_net_ipv4_icmp_ignore_bogus_error_responses
    - sysctl_net_ipv4_tcp_syncookies
    - sysctl_net_ipv4_conf_all_send_redirects
    - sysctl_net_ipv4_conf_default_send_redirects
    - sysctl_net_ipv4_ip_forward
    - package_nftables_removed
    - permissions_local_var_log
    - mount_option_dev_shm_noexec
    - sysctl_fs_suid_dumpable
    - sysctl_kernel_randomize_va_space
    - file_at_deny_not_exist
    - file_cron_deny_not_exist
    - package_rpcbind_removed
    - package_net-snmp_removed
    - sshd_set_keepalive
    - disable_host_auth
    - sshd_disable_empty_passwords
    - sshd_disable_rhosts
    - sshd_do_not_permit_user_env
    - sshd_set_max_auth_tries
    - sshd_use_strong_kex
    # remove some rules in pcs-hardening
    - '!accounts_umask_etc_login_defs'
    - '!accounts_umask_etc_profile'
    - '!sshd_disable_root_login'
    - '!sshd_set_max_auth_tries'
