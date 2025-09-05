documentation_complete: true

reference: https://docs-prv.pcisecuritystandards.org/PCI%20DSS/Standard/PCI-DSS-v4_0_1.pdf

title: 'DRAFT - PCI-DSS v4.0.1 Control Baseline for Oracle Linux 10'

description: |-
    This is a draft profile for experimental purposes.

    Payment Card Industry - Data Security Standard (PCI-DSS) is a set of
    security standards designed to ensure the secure handling of payment card
    data, with the goal of preventing data breaches and protecting sensitive
    financial information.

    This draft profile ensures Oracle Linux 10 is configured in alignment
    with PCI-DSS v4.0.1 requirements.

selections:
    - pcidss_4:all
    - var_password_hashing_algorithm=yescrypt
    - var_password_hashing_algorithm_pam=yescrypt

    # these rules do not apply to OL 10
    - '!package_audit-audispd-plugins_installed'
    - '!package_dhcp_removed'
    - '!package_ypserv_removed'
    - '!package_ypbind_removed'
    - '!package_talk_removed'
    - '!package_talk-server_removed'
    - '!package_xinetd_removed'
    - '!package_rsh_removed'
    - '!package_rsh-server_removed'

    - '!service_ntp_enabled'
    - '!service_ntpd_enabled'
    - '!service_timesyncd_enabled'
    - '!ntpd_specify_remote_server'
    - '!ntpd_specify_multiple_servers'

    - '!accounts_passwords_pam_tally2'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!cracklib_accounts_password_pam_dcredit'
    - '!cracklib_accounts_password_pam_lcredit'
    - '!cracklib_accounts_password_pam_minlen'
    - '!cracklib_accounts_password_pam_retry'
    - '!ensure_firewall_rules_for_open_ports'
    - '!ensure_shadow_group_empty'
    - '!ensure_suse_gpgkey_installed'
    - '!ensure_almalinux_gpgkey_installed'
    - '!install_PAE_kernel_on_x86-32'
    - '!mask_nonessential_services'
    - '!nftables_ensure_default_deny_policy'
    - '!set_ipv6_loopback_traffic'
    - '!set_ip6tables_default_rule'
    - '!set_loopback_traffic'
    - '!set_password_hashing_algorithm_commonauth'

    # Following are incompatible with the ol10 product
    - '!service_chronyd_or_ntpd_enabled'
    - '!aide_periodic_checking_systemd_timer'
    - '!gnome_gdm_disable_unattended_automatic_login'
    - '!permissions_local_var_log'
    - '!sshd_use_strong_kex'
    - '!sshd_use_approved_macs'
    - '!sshd_use_approved_ciphers'
    - '!security_patches_up_to_date'
    - '!kernel_module_dccp_disabled'

    # Add oracle gpg key rule
    - 'ensure_oracle_gpgkey_installed'
    - '!ensure_redhat_gpgkey_installed'
