documentation_complete: true

metadata:
    version: '4.0'
    SMEs:
        - marcusburghardt
        - mab879
        - vojtapolasek

reference: https://docs-prv.pcisecuritystandards.org/PCI%20DSS/Standard/PCI-DSS-v4_0.pdf

title: 'PCI-DSS v4.0 Control Baseline for Red Hat Enterprise Linux 7'

description: |-
    Payment Card Industry - Data Security Standard (PCI-DSS) is a set of
    security standards designed to ensure the secure handling of payment card
    data, with the goal of preventing data breaches and protecting sensitive
    financial information.

    This profile ensures Red Hat Enterprise Linux 7 is configured in alignment
    with PCI-DSS v4.0 requirements.

selections:
    - pcidss_4:all
    # More tests are needed to identify which rule is conflicting with rpm_verify_permissions.
    # https://github.com/ComplianceAsCode/content/issues/11285
    - '!rpm_verify_permissions'
    # these rules do not apply to RHEL but they have to keep the prodtype for historical reasons
    - '!package_audit-audispd-plugins_installed'
    - '!service_ntp_enabled'
    - '!set_ipv6_loopback_traffic'
    - '!set_loopback_traffic'
    - '!timer_logrotate_enabled'
    # Following rules once had a prodtype incompatible with the rhel7 product
    - '!sysctl_kernel_core_pattern'
    - '!configure_crypto_policy'
    - '!mask_nonessential_services'
    - '!aide_periodic_checking_systemd_timer'
    - '!file_permissions_at_allow'
    - '!firewalld_loopback_traffic_restricted'
    - '!cracklib_accounts_password_pam_lcredit'
    - '!file_owner_at_allow'
    - '!ensure_firewall_rules_for_open_ports'
    - '!cracklib_accounts_password_pam_retry'
    - '!permissions_local_var_log'
    - '!accounts_passwords_pam_tally2'
    - '!ensure_suse_gpgkey_installed'
    - '!gnome_gdm_disable_unattended_automatic_login'
    - '!file_groupowner_at_allow'
    - '!configure_ssh_crypto_policy'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!enable_authselect'
    - '!cracklib_accounts_password_pam_minlen'
    - '!set_password_hashing_algorithm_commonauth'
    - '!cracklib_accounts_password_pam_dcredit'
    - '!firewalld_loopback_traffic_trusted'
    - '!service_timesyncd_enabled'
