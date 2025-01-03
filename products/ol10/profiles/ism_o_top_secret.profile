documentation_complete: true

reference: https://www.cyber.gov.au/ism

title: 'DRAFT - Australian Cyber Security Centre (ACSC) ISM Official - Top Secret'

description: |-
    This is a draft profile for experimental purposes.

    This draft profile contains configuration checks for Oracle Linux 10
    that align to the Australian Cyber Security Centre (ACSC) Information Security Manual (ISM).

    The ISM uses a risk-based approach to cyber security. This profile provides a guide to aligning
    Oracle Linux security controls with the ISM, which can be used to select controls
    specific to an organisation's security posture and risk profile.

    A copy of the ISM can be found at the ACSC website:

    https://www.cyber.gov.au/ism

extends: e8

selections:
    - ism_o:all:top_secret

    # these rules do not work properly on OL 10 for now
    - '!enable_dracut_fips_module'
    - '!firewalld_sshd_port_enabled'
    - '!require_singleuser_auth'

    # lastlog is not used in OL 10
    - '!audit_rules_login_events_lastlog'

    # Setting any nondefault, so a specific driver is expected
    # using the same as in STIG
    - var_smartcard_drivers=cac

    # ISM 0418,1055,1402
    # Rule is for authconfig not used in OL10
    - "!enable_ldap_client"
    # Not applicable to OL10 due to krb5-server version
    - "!kerberos_disable_no_keytab"

    # ISM 1386
    # Configuration not available in OL10
    - "!force_opensc_card_drivers"

    # ISM 1277,1552
    # Not applicable to OL10 as per openssl man page
    - "!openssl_use_strong_entropy"     

    # ISM 0988,1405
    # Always use chronyd
    - "!service_chronyd_or_ntpd_enabled"

    # ISM 0421,0422,0431,0974,1173,1401,1504,1505,1546,1557,1558,1559,1560,1561
    # pam_tally2 is not available in OL10
    - "!accounts_passwords_pam_tally2_deny_root"
    - "!accounts_passwords_pam_tally2_unlock_time"
    - '!audit_rules_login_events_tallylog'

    # ISM 0582,0846
    # These rules are not implemented in OL10
    - "!audit_access_failed_aarch64"
    - "!audit_access_failed_ppc64le"
    - "!audit_access_success_aarch64"
    - "!audit_access_success_ppc64le"

    # Doesn't cover the expected requirement 
    # 1319 "Static addressing is not used..."
    - "!network_ipv6_static_address"

    # ISM 1467,1483,1493
    # Packages not available in OL
    - "!package_libdnf-plugin-subscription-manager_installed"
    - "!package_subscription-manager_installed"
