---
documentation_complete: true

metadata:
    SMEs:
        - shaneboulden
        - wcushen
        - eliseelk
        - sashperso
        - anjuskantha

reference: https://www.cyber.gov.au/ism

title: 'Australian Cyber Security Centre (ACSC) ISM Official'

description: |-
    This profile contains configuration checks for Red Hat Enterprise Linux 9
    that align to the Australian Cyber Security Centre (ACSC) Information Security Manual (ISM)
    with the applicability marking of OFFICIAL.

    The ISM uses a risk-based approach to cyber security. This profile provides a guide to aligning
    Red Hat Enterprise Linux security controls with the ISM, which can be used to select controls
    specific to an organisation's security posture and risk profile.

    A copy of the ISM can be found at the ACSC website:

    https://www.cyber.gov.au/ism

extends: e8

selections:
    - ism_o:all
    - '!accounts_password_pam_ocredit'
    - '!audit_rules_unsuccessful_file_modification_truncate'
    - '!set_password_hashing_algorithm_systemauth'
    - '!network_ipv6_static_address'
    - '!audit_rules_unsuccessful_file_modification_ftruncate'
    - '!kerberos_disable_no_keytab'
    - '!audit_access_success_aarch64'
    - '!audit_rules_unsuccessful_file_modification_creat'
    - '!sebool_kerberos_enabled'
    - '!force_opensc_card_drivers'
    - '!package_subscription-manager_installed'
    - '!system_booted_in_fips_mode'
    - '!accounts_password_pam_minclass'
    - '!dnf-automatic_apply_updates'
    - '!set_password_hashing_algorithm_passwordauth'
    - '!chronyd_or_ntpd_specify_multiple_servers'
    - '!sebool_authlogin_radius'
    - '!configure_kerberos_crypto_policy'
    - '!set_password_hashing_algorithm_libuserconf'
    - '!audit_rules_unsuccessful_file_modification_openat'
    - '!sssd_enable_smartcards'
    - '!openssl_use_strong_entropy'
    - '!accounts_password_pam_ucredit'
    - '!service_chronyd_or_ntpd_enabled'
    - '!package_opensc_installed'
    - '!accounts_password_pam_lcredit'
    - '!enable_ldap_client'
    - '!package_libdnf-plugin-subscription-manager_installed'
    - '!sebool_authlogin_nsswitch_use_ldap'
    - '!chronyd_configure_pool_and_server'
    - '!set_password_hashing_algorithm_logindefs'
    - '!service_pcscd_enabled'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!package_pcsc-lite-ccid_installed'
    - '!package_pcsc-lite_installed'
    - '!audit_rules_unsuccessful_file_modification_open'
    - '!configure_opensc_card_drivers'
    - '!audit_access_success_ppc64le'
    - '!accounts_password_pam_dcredit'
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!audit_access_failed_ppc64le'
    - '!audit_access_failed_aarch64'
    - '!secure_boot_enabled'
    - '!audit_rules_unsuccessful_file_modification_open_by_handle_at'
    - '!accounts_password_minlen_login_defs'
    - usbguard_allow_hid_and_hub
    - sshd_allow_only_protocol2
    - accounts_password_all_shadowed
