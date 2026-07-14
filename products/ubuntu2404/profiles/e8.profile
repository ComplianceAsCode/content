---
documentation_complete: true

metadata:
    SMEs:
        - ndfivegn

reference: https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

title: 'Australian Cyber Security Centre (ACSC) Essential Eight'

description: |-
    This profile contains configuration checks for Ubuntu 24.04
    that align to the Australian Cyber Security Centre (ACSC) Essential Eight.

    A copy of the Essential Eight in Linux Environments guide can be found at the
    ACSC website:

    https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

selections:
    - e8:all

    # The e8 control file maps each requirement to Red Hat Enterprise Linux
    # rules. The unselections below drop rules that are not applicable to Ubuntu
    # (SELinux, RPM, dnf/yum, authselect, firewalld, system-wide crypto-policies),
    # and the additions re-cover the same control areas with their Ubuntu
    # equivalents (AppArmor, ufw, apt) so coverage parity with the RHEL/OL e8
    # profile is preserved.

    ### Application control (fapolicyd -> AppArmor)
    - '!package_fapolicyd_installed'
    - '!service_fapolicyd_enabled'
    - package_apparmor_installed
    - all_apparmor_profiles_enforced

    ### Network firewall (firewalld -> ufw)
    - '!package_firewalld_installed'
    - '!service_firewalld_enabled'
    - package_ufw_installed
    - service_ufw_enabled

    ### Package authenticity (dnf/yum gpgcheck -> apt)
    - '!ensure_redhat_gpgkey_installed'
    - '!ensure_gpgcheck_globally_activated'
    - '!ensure_gpgcheck_local_packages'
    - '!ensure_gpgcheck_never_disabled'
    - '!package_sequoia-sq_installed'
    - apt_conf_disallow_unauthenticated

    ### Automatic patching (dnf-automatic -> unattended-upgrades)
    - '!dnf-automatic_security_updates_only'
    - package_unattended-upgrades_installed

    ### Mandatory access control (SELinux -> AppArmor, covered above)
    - '!selinux_state'
    - '!selinux_policytype'
    - '!audit_rules_execution_restorecon'
    - '!audit_rules_execution_semanage'
    - '!audit_rules_execution_setsebool'
    - '!audit_rules_execution_setfiles'
    - '!audit_rules_execution_seunshare'

    ### RPM-based integrity verification (no dpkg equivalent rule upstream)
    - '!rpm_verify_hashes'
    - '!rpm_verify_permissions'
    - '!rpm_verify_ownership'
    - '!file_permissions_unauthorized_sgid'
    - '!file_permissions_unauthorized_suid'

    ### System-wide crypto policy / authselect (RHEL-only mechanisms)
    - '!configure_crypto_policy'
    - '!configure_ssh_crypto_policy'
    - '!enable_authselect'

    ### RHEL-only kernel sysctl / legacy lockout audit
    - '!sysctl_kernel_exec_shield'
    - '!audit_rules_login_events_tallylog'
