---
documentation_complete: true

metadata:
    version: '4.0.1'
    SMEs:
        - svet-se
        - teacup-on-rockingchair

reference: https://docs-prv.pcisecuritystandards.org/PCI%20DSS/Standard/PCI-DSS-v4_0_1.pdf

title: 'PCI-DSS v4.0.1 Control Baseline for SUSE Linux Enterprise Micro 6'

description: |-
    Payment Card Industry - Data Security Standard (PCI-DSS) is a set of
    security standards designed to ensure the secure handling of payment card
    data, with the goal of preventing data breaches and protecting sensitive
    financial information.

    This profile ensures SUSE Linux Enterprise Micro 6 is configured in
    alignment with PCI-DSS v4.0.1 requirements. The rule set comes from
    controls/pcidss_4.yml. Selections below only override values that the
    control file tells a product to set, or remove rules for components that
    are not part of the SLE Micro 6 image.

selections:
    - pcidss_4:all:base
    - var_accounts_passwords_pam_faillock_dir=run
    - var_accounts_tmout=15_min
    - var_multiple_time_servers=suse
    - var_multiple_time_pools=suse
    - sshd_strong_kex=pcidss
    - sshd_approved_ciphers=slmicro6
    - sshd_approved_macs=slmicro6
    - '!use_pam_wheel_for_su'
    - '!ensure_redhat_gpgkey_installed'
    - '!ensure_almalinux_gpgkey_installed'
    - '!package_sequoia-sq_installed'
    - '!enable_authselect'
    - '!accounts_passwords_pam_tally2'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!cracklib_accounts_password_pam_retry'
    - accounts_password_pam_retry
    - '!cracklib_accounts_password_pam_dcredit'
    - '!cracklib_accounts_password_pam_lcredit'
    - '!cracklib_accounts_password_pam_minlen'
    - accounts_passwords_pam_faillock_unlock_time_with_zero
    - '!accounts_passwords_pam_faillock_unlock_time'
    - '!accounts_password_pam_unix_remember'
    - '!accounts_password_pam_pwhistory_remember_system_auth'
    - '!accounts_password_pam_pwhistory_remember_password_auth'
    - '!service_ntp_enabled'
    - '!service_ntpd_enabled'
    - '!service_timesyncd_enabled'
    - '!ntpd_specify_remote_server'
    - '!ntpd_specify_multiple_servers'
    - '!aide_periodic_cron_checking'
    - '!package_cron_installed'
    - '!file_cron_deny_not_exist'
    - '!file_groupowner_cron_allow'
    - '!file_owner_cron_allow'
    - '!file_permissions_cron_allow'
    - '!file_groupowner_crontab'
    - '!file_owner_crontab'
    - '!file_permissions_crontab'
    - '!file_groupowner_cron_d'
    - '!file_owner_cron_d'
    - '!file_permissions_cron_d'
    - '!file_groupowner_cron_hourly'
    - '!file_owner_cron_hourly'
    - '!file_permissions_cron_hourly'
    - '!file_groupowner_cron_daily'
    - '!file_owner_cron_daily'
    - '!file_permissions_cron_daily'
    - '!file_groupowner_cron_weekly'
    - '!file_owner_cron_weekly'
    - '!file_permissions_cron_weekly'
    - '!file_groupowner_cron_monthly'
    - '!file_owner_cron_monthly'
    - '!file_permissions_cron_monthly'
    - '!file_at_deny_not_exist'
    - '!file_groupowner_at_allow'
    - '!file_owner_at_allow'
    - '!file_permissions_at_allow'
    - '!enable_dconf_user_profile'
    - '!dconf_db_up_to_date'
    - '!dconf_gnome_session_idle_user_locks'
    - '!dconf_gnome_screensaver_idle_activation_enabled'
    - '!dconf_gnome_screensaver_idle_delay'
    - '!dconf_gnome_screensaver_lock_delay'
    - '!dconf_gnome_screensaver_lock_enabled'
    - '!dconf_gnome_screensaver_mode_blank'
    - '!dconf_gnome_disable_automount'
    - '!dconf_gnome_disable_automount_open'
    - '!gnome_gdm_disable_guest_login'
    - '!gnome_gdm_disable_automatic_login'
    - '!gnome_gdm_disable_unattended_automatic_login'
    - '!file_owner_user_cfg'
    - '!file_groupowner_user_cfg'
    - '!file_permissions_user_cfg'
    - '!nftables_ensure_default_deny_policy'
    - '!set_ip6tables_default_rule'
    - '!set_ipv6_loopback_traffic'
    - '!set_loopback_traffic'
    - '!firewalld_loopback_traffic_restricted'
    - '!package_rsh_removed'
    - '!package_rsh-server_removed'
    - '!package_talk_removed'
    - '!package_talk-server_removed'
    - '!package_ftp_removed'
    - '!package_xinetd_removed'
    - '!package_ypbind_removed'
    - '!package_ypserv_removed'
    - '!install_PAE_kernel_on_x86-32'
    - '!rpm_verify_permissions'
    - '!package_audispd-plugins_installed'
    - '!audit_rules_dac_modification_fchmodat2'
    - '!sysctl_kernel_core_pattern'
    - '!file_group_ownership_var_log_audit'
    - '!set_password_hashing_algorithm_libuserconf'
    - '!audit_rules_login_events_tallylog'
    - '!network_nmcli_permissions'
    - '!package_cryptsetup-luks_installed'
    - '!package_libreswan_installed'
    - '!package_postfix_installed'
    - '!ensure_root_password_configured'
    - '!no_password_auth_for_systemaccounts'
