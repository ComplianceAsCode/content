---
documentation_complete: true

metadata:
    SMEs:
        - ndfivegn

reference: https://www.cyber.gov.au/ism

title: 'Australian Cyber Security Centre (ACSC) ISM Official'

description: |-
    This profile contains configuration checks for Ubuntu 22.04
    that align to the Australian Cyber Security Centre (ACSC) Information Security Manual (ISM)
    with the applicability marking of OFFICIAL.

    The ISM uses a risk-based approach to cyber security. This profile provides a guide to aligning
    Ubuntu security controls with the ISM, which can be used to select controls
    specific to an organisation's security posture and risk profile.

    A copy of the ISM can be found at the ACSC website:

    https://www.cyber.gov.au/ism

selections:
    # The ISM Official baseline includes the ACSC Essential Eight. This profile
    # is self-contained: it selects all rules from both the e8 and ism_o control
    # files directly rather than extending the e8 profile.
    - e8:all
    - ism_o:all

    # Both control files map each requirement to Red Hat Enterprise Linux rules.
    # The unselections below drop rules not applicable to Ubuntu; the additions
    # re-cover the affected control areas with their Ubuntu equivalents so that
    # every control covered by the RHEL/OL ism_o profile is also covered here.

    # ISM-1416 (Guidelines for system hardening): "A software firewall is
    # implemented on workstations and servers to restrict inbound and outbound
    # network connections to an organisation-approved set of applications and
    # services." Ubuntu ships ufw rather than firewalld.
    - '!package_firewalld_installed'
    - '!service_firewalld_enabled'
    - '!configure_firewalld_ports'
    - '!firewalld_sshd_port_enabled'
    - '!set_firewalld_default_zone'
    - package_ufw_installed
    - service_ufw_enabled
    - ufw_default_incoming_rule

    # ISM-1446 (Guidelines for cryptography): "When using elliptic curve
    # cryptography, a suitable curve from NIST SP 800-186 is used." On RHEL this
    # is enforced through system-wide crypto-policies; Ubuntu has no equivalent
    # mechanism, so the approved curve/cipher set is enforced on the SSH server.
    - '!configure_crypto_policy'
    - '!configure_ssh_crypto_policy'
    - '!configure_kerberos_crypto_policy'
    - '!enable_fips_mode'
    - '!enable_dracut_fips_module'
    - '!system_booted_in_fips_mode'
    - sshd_use_strong_ciphers
    - sshd_use_strong_macs
    - sshd_use_strong_kex
    # Retained from the ism_o baseline for parity with the RHEL/OL profile. Inert
    # on Ubuntu: its only consumer, configure_crypto_policy, is unselected above
    # and Ubuntu has no system-wide crypto-policy mechanism.
    - var_system_crypto_policy=fips

    # ISM-1493 (Guidelines for system management): "Software registers for
    # workstations, servers, network devices and networked IT equipment are
    # developed, implemented, maintained and regularly verified." The RHEL
    # mapping verifies package provenance via dnf/yum gpgcheck; on Ubuntu this
    # is apt package authentication.
    - '!ensure_gpgcheck_globally_activated'
    - '!ensure_gpgcheck_local_packages'
    - '!ensure_gpgcheck_never_disabled'
    - '!ensure_redhat_gpgkey_installed'
    - '!ensure_oracle_gpgkey_installed'
    - '!package_sequoia-sq_installed'
    - apt_conf_disallow_unauthenticated
    - apt_sources_list_official

    # ISM-1467 / ISM-1483 (Guidelines for system hardening): "The latest release
    # of email clients, office productivity suites, PDF applications, security
    # products and web browsers ... are used." / "The latest release of
    # internet-facing server applications is used." dnf-automatic provides
    # automatic patching on RHEL; the Ubuntu equivalent is unattended-upgrades
    # (package_unattended-upgrades_installed, added by this change).
    - '!dnf-automatic_apply_updates'
    - '!dnf-automatic_security_updates_only'
    - '!package_libdnf-plugin-subscription-manager_installed'
    - '!package_subscription-manager_installed'
    - package_unattended-upgrades_installed

    # ISM-1657 (Guidelines for system hardening): "Application control restricts
    # the execution of executables, libraries, scripts, installers ... to an
    # organisation-approved set." fapolicyd is the RHEL mechanism; Ubuntu uses
    # AppArmor.
    - '!package_fapolicyd_installed'
    - '!service_fapolicyd_enabled'
    - package_apparmor_installed
    - all_apparmor_profiles_enforced

    ### SELinux (Ubuntu uses AppArmor)
    - '!selinux_state'
    - '!selinux_policytype'
    - '!sebool_kerberos_enabled'
    - '!sebool_authlogin_nsswitch_use_ldap'
    - '!sebool_authlogin_radius'
    - '!sebool_auditadm_exec_content'
    - '!audit_rules_execution_restorecon'
    - '!audit_rules_execution_semanage'
    - '!audit_rules_execution_setfiles'
    - '!audit_rules_execution_setsebool'
    - '!audit_rules_execution_seunshare'

    ### RPM-based integrity verification (no dpkg equivalent rule upstream)
    - '!rpm_verify_hashes'
    - '!rpm_verify_ownership'
    - '!rpm_verify_permissions'
    - '!file_permissions_unauthorized_sgid'
    - '!file_permissions_unauthorized_suid'

    ### RHEL-only config files / tooling
    - '!enable_ldap_client'
    - '!network_nmcli_permissions'
    - '!network_ipv6_static_address'
    - '!openssl_use_strong_entropy'
    - '!sysctl_kernel_exec_shield'
    - '!enable_authselect'

    ### RHEL/SLES PAM stack and legacy account lockout
    - '!set_password_hashing_algorithm_libuserconf'
    - '!set_password_hashing_algorithm_passwordauth'
    - '!accounts_passwords_pam_faillock_deny_root'
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!audit_rules_login_events_tallylog'

    ### Legacy SSH protocol (inherent on modern OpenSSH)
    - '!sshd_allow_only_protocol2'
