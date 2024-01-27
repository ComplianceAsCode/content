documentation_complete: true

metadata:
    version: '4.0'
    SMEs:
        - marcusburghardt
        - mab879
        - vojtapolasek

reference: https://docs-prv.pcisecuritystandards.org/PCI%20DSS/Standard/PCI-DSS-v4_0.pdf

title: 'PCI-DSS v4.0 Control Baseline for Red Hat Enterprise Linux 9'

description: |-
    Payment Card Industry - Data Security Standard (PCI-DSS) is a set of
    security standards designed to ensure the secure handling of payment card
    data, with the goal of preventing data breaches and protecting sensitive
    financial information.

    This profile ensures Red Hat Enterprise Linux 9 is configured in alignment
    with PCI-DSS v4.0 requirements.

selections:
    - pcidss_4:all
    # audit-audispd-plugins package does not exist in RHEL 9
    # use only package_audispd-plugins_installed
    - '!package_audit-audispd-plugins_installed'
    # More tests are needed to identify which rule is conflicting with rpm_verify_permissions.
    # https://github.com/ComplianceAsCode/content/issues/11285
    - '!rpm_verify_permissions'
    # these rules do not apply to RHEL but they have to keep the prodtype for historical reasons
    - '!package_audit-audispd-plugins_installed'
    - '!service_ntp_enabled'
    - '!ntpd_specify_remote_server'
    - '!ntpd_specify_multiple_servers'
    - '!set_ipv6_loopback_traffic'
    - '!set_loopback_traffic'
    - '!service_ntpd_enabled'
    - '!package_ypserv_removed'
    - '!package_ypbind_removed'
    - '!package_talk_removed'
    - '!package_talk-server_removed'
    - '!package_xinetd_removed'
    - '!package_rsh_removed'
    - '!package_rsh-server_removed'
    # Following rules once had a prodtype incompatible with the rhel9 product
    - '!service_chronyd_or_ntpd_enabled'
    - '!install_PAE_kernel_on_x86-32'
    - '!mask_nonessential_services'
    - '!aide_periodic_checking_systemd_timer'
    - '!nftables_ensure_default_deny_policy'
    - '!cracklib_accounts_password_pam_lcredit'
    - '!file_owner_at_allow'
    - '!ensure_firewall_rules_for_open_ports'
    - '!cracklib_accounts_password_pam_retry'
    - '!gnome_gdm_disable_guest_login'
    - '!sshd_use_strong_kex'
    - '!sshd_use_approved_macs'
    - '!group_unique_name'
    - '!permissions_local_var_log'
    - '!sshd_use_approved_ciphers'
    - '!accounts_passwords_pam_tally2'
    - '!ensure_suse_gpgkey_installed'
    - '!gnome_gdm_disable_unattended_automatic_login'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!cracklib_accounts_password_pam_minlen'
    - '!set_password_hashing_algorithm_commonauth'
    - '!cracklib_accounts_password_pam_dcredit'
    - '!ensure_shadow_group_empty'
    - '!service_timesyncd_enabled'
