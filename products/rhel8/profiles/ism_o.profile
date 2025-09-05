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
    This profile contains configuration checks for Red Hat Enterprise Linux 8
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
    # Add rules missing from the control file that where in RHEL 8
    - accounts_password_all_shadowed
    - usbguard_allow_hid_and_hub
    - sshd_allow_only_protocol2
    # Remove rules that where not the original profile for RHEL 8
    - '!accounts_password_minlen_login_defs'
    - '!accounts_password_pam_dcredit'
    - '!accounts_password_pam_lcredit'
    - '!accounts_password_pam_minclass'
    - '!accounts_password_pam_ocredit'
    - '!accounts_password_pam_ucredit'
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!audit_access_failed_aarch64'
    - '!audit_access_failed_ppc64le'
    - '!audit_access_success_aarch64'
    - '!audit_access_success_ppc64le'
    - '!audit_rules_unsuccessful_file_modification_creat'
    - '!audit_rules_unsuccessful_file_modification_ftruncate'
    - '!audit_rules_unsuccessful_file_modification_open'
    - '!audit_rules_unsuccessful_file_modification_openat'
    - '!audit_rules_unsuccessful_file_modification_open_by_handle_at'
    - '!audit_rules_unsuccessful_file_modification_truncate'
    - '!chronyd_configure_pool_and_server'
    - '!configure_kerberos_crypto_policy'
    - '!configure_opensc_card_drivers'
    - '!dnf-automatic_apply_updates'
    - '!enable_dracut_fips_module'
    - '!enable_ldap_client'
    - '!force_opensc_card_drivers'
    - '!kerberos_disable_no_keytab'
    - '!network_ipv6_static_address'
    - '!package_audit_installed'
    - '!package_libdnf-plugin-subscription-manager_installed'
    - '!package_opensc_installed'
    - '!package_pcsc-lite-ccid_installed'
    - '!package_pcsc-lite_installed'
    - '!package_subscription-manager_installed'
    - '!sebool_authlogin_nsswitch_use_ldap'
    - '!sebool_authlogin_radius'
    - '!sebool_kerberos_enabled'
    - '!secure_boot_enabled'
    - '!service_pcscd_enabled'
    - '!set_password_hashing_algorithm_libuserconf'
    - '!set_password_hashing_algorithm_logindefs'
    - '!set_password_hashing_algorithm_passwordauth'
    - '!set_password_hashing_algorithm_systemauth'
    - '!sssd_enable_smartcards'
    - '!system_booted_in_fips_mode'
    # Adjust variables to match the origianl RHEL 8 profiles
    - var_password_hashing_algorithm_pam=sha512
    - var_accounts_password_minlen_login_defs=15
