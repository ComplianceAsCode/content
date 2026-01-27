---
documentation_complete: true

metadata:
    version: '4.0.1'
    SMEs:
        - svet-se
        - teacup-on-rockingchair

reference: https://docs-prv.pcisecuritystandards.org/PCI%20DSS/Standard/PCI-DSS-v4_0_1.pdf

title: 'PCI-DSS v4.0.1 Control Baseline for SUSE Linux Enterprise 16'

description: |-
    Payment Card Industry - Data Security Standard (PCI-DSS) is a set of
    security standards designed to ensure the secure handling of payment card
    data, with the goal of preventing data breaches and protecting sensitive
    financial information.

    This profile ensures SUSE Linux Enterprise 16 is configured in alignment
    with PCI-DSS v4.0.1 requirements.

selections:
    - pcidss_4:all:base
    - ensure_pam_wheel_group_empty
    - sshd_strong_kex=pcidss
    - var_multiple_time_servers=suse
    - var_multiple_time_pools=suse
    - var_accounts_tmout=15_min
    - audit_rules_enable_syscall_auditing
    - '!ntpd_specify_multiple_servers'
    - '!ntpd_specify_remote_server'
    - '!service_ntp_enabled'
    - '!service_ntpd_enabled'
    - '!service_timesyncd_enabled'
    - '!package_libreswan_installed'
    - '!use_pam_wheel_for_su'
    - '!aide_periodic_cron_checking'
    - '!accounts_password_pam_dcredit'
    - '!accounts_password_pam_pwhistory_remember_system_auth'
    - '!sysctl_kernel_core_pattern'
    - '!configure_firewalld_ports'
    - '!accounts_passwords_pam_tally2'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!audit_rules_login_events_tallylog'
    - '!accounts_passwords_pam_faillock_deny'
    - '!file_owner_user_cfg'
    - '!accounts_passwords_pam_faillock_unlock_time'
    - '!ensure_redhat_gpgkey_installed'
    - '!package_sequoia-sq_installed'
    - '!ensure_almalinux_gpgkey_installed'
    - '!firewalld_loopback_traffic_restricted'
    - '!accounts_password_pam_lcredit'
    - '!file_group_ownership_var_log_audit'
    - '!package_ftp_removed'
    - '!gnome_gdm_disable_guest_login'
    - '!accounts_password_pam_minlen'
    - '!no_password_auth_for_systemaccounts'
    - '!file_groupowner_user_cfg'
    - '!ensure_root_password_configured'
    - '!gnome_gdm_disable_automatic_login'
    - '!accounts_password_pam_pwhistory_remember_password_auth'
    - '!enable_authselect'
    - '!file_permissions_user_cfg'
    - '!package_audispd-plugins_installed'
    - '!firewalld_loopback_traffic_trusted'
    - '!network_nmcli_permissions'
    - '!package_cryptsetup-luks_installed'
    - '!audit_rules_dac_modification_fchmodat2'
    - '!accounts_password_pam_unix_remember'
    - '!package_rsh-server_removed'
    - '!package_rsh_removed'
    - '!package_talk-server_removed'
    - '!package_talk_removed'
    - '!package_xinetd_removed'
    - '!package_ypbind_removed'
    - '!package_ypserv_removed'
    - '!rpm_verify_permissions'
    - '!sshd_use_approved_ciphers'
    - '!sshd_use_approved_macs'
    - '!set_password_hashing_algorithm_libuserconf'
    - '!set_ip6tables_default_rule'
    - '!set_ipv6_loopback_traffic'
    - '!set_loopback_traffic'
    - '!nftables_ensure_default_deny_policy'
