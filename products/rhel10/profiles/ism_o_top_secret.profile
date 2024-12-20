documentation_complete: true

metadata:
    SMEs:
        - shaneboulden
        - wcushen
        - eliseelk
        - sashperso
        - anjuskantha

reference: https://www.cyber.gov.au/ism

title: 'DRAFT - Australian Cyber Security Centre (ACSC) ISM Official - Top Secret'

description: |-
    This draft profile contains configuration checks for Red Hat Enterprise Linux 10
    that align to the Australian Cyber Security Centre (ACSC) Information Security Manual (ISM).

    The ISM uses a risk-based approach to cyber security. This profile provides a guide to aligning
    Red Hat Enterprise Linux security controls with the ISM, which can be used to select controls
    specific to an organisation's security posture and risk profile.

    A copy of the ISM can be found at the ACSC website:

    https://www.cyber.gov.au/ism

extends: e8

selections:
    - ism_o:all:top_secret
    # these rules do not work properly on RHEL 10 for now
    - '!enable_dracut_fips_module'
    - '!firewalld_sshd_port_enabled'
    - '!require_singleuser_auth'
    # tally2 is deprecated, replaced by faillock
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!audit_rules_login_events_tallylog'
    # lastlog is not used in RHEL 10
    - '!audit_rules_login_events_lastlog'
    # this rule is currently failing on some systemd services, probably because of require_emergency_target_auth and require_singleuser_auth rules
    - '!rpm_verify_hashes'
    # this rule should not be needed anymore on RHEL 10, but investigation is recommended
    - '!openssl_use_strong_entropy'
    # Currently not working RHEL 10, changes are being made to FIPS mode. Investigation is recommended.
    - '!enable_dracut_fips_module'
    # This rule is not applicable for RHEL 10
    - '!force_opensc_card_drivers'
    - '!service_chronyd_or_ntpd_enabled'
