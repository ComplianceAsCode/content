documentation_complete: true

reference: https://www.cyber.gov.au/ism

title: 'Australian Cyber Security Centre (ACSC) ISM Official - Top Secret'

description: |-
    This profile contains configuration checks for Oracle Linux 9
    that align to the Australian Cyber Security Centre (ACSC) Information Security Manual (ISM).

    The ISM uses a risk-based approach to cyber security. This profile provides a guide to aligning 
    Oracle Linux security controls with the ISM, which can be used to select controls 
    specific to an organisation's security posture and risk profile.

    A copy of the ISM can be found at the ACSC website:

    https://www.cyber.gov.au/ism

extends: e8

selections:
    - ism_o:all:top_secret

    # Setting any nondefault, so it is safer to spot an issue
    - var_smartcard_drivers=cac

    # Rule is for authconfig not used in OL9
    - "!enable_ldap_client"

    # Configuration not available in OL9
    - "!force_opensc_card_drivers"

    # Not applicable to OL9 due to krb5-server version
    - "!kerberos_disable_no_keytab"

    # Doesn't seem applicable to OL9 as per openssl man page
    - "!openssl_use_strong_entropy"     

    # Always use chronyd
    - "!service_chronyd_or_ntpd_enabled"

    # pam_tally2 not available in OL9
    - "!accounts_passwords_pam_tally2_deny_root"
    - "!accounts_passwords_pam_tally2_unlock_time"

    # This divition of rules is not implemented in OL9
    - "!audit_access_failed_aarch64"
    - "!audit_access_failed_ppc64le"
    - "!audit_access_success_aarch64"
    - "!audit_access_success_ppc64le"

    # Doesn't seem to cover the expected requirement
    - "!network_ipv6_static_address"

    # Packages not available in OL
    - "!package_libdnf-plugin-subscription-manager_installed"
    - "!package_subscription-manager_installed"
