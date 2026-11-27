---
documentation_complete: true

metadata:
    version: 4.3
    SMEs:
        - ggbecker
        - matusmarhefka

reference: https://www.niap-ccevs.org/Profile/Info.cfm?PPID=469&id=469

title: 'Protection Profile for General Purpose Operating Systems'

description: |-
    This profile configures AlmaLinux OS 9 according to the Protection Profile
    for General Purpose Operating Systems (OSPP) version 4.3 and Functional
    Package for SSH version 1.0, following the Red Hat Enterprise Linux 9
    Common Criteria Guidance documentation for Target of Evaluation.

    Where appropriate, CNSSI 1253 or DoD-specific values are used for
    configuration, based on Configuration Annex to the OSPP.

selections:
    - ospp:all
    - enable_authselect
    - var_authselect_profile=minimal
    - audit_service_management
    - audit_service_management_ppc64le
    # Red Hat subscription management does not apply to AlmaLinux OS
    - '!package_dnf-plugin-subscription-manager_installed'
    - '!package_subscription-manager_installed'
    # AlmaLinux OS packages are signed with the AlmaLinux key, not the Red Hat one
    - '!ensure_redhat_gpgkey_installed'
    - ensure_almalinux_gpgkey_installed
    - '!package_sequoia-sq_installed'
    - '!configure_ssh_crypto_policy'
