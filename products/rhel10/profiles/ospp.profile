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
    This profile is based on the Red Hat Enterprise Linux 10 Common Criteria Guidance.

    Where appropriate, CNSSI 1253 or DoD-specific values are used for
    configuration, based on Configuration Annex to the OSPP.

selections:
    - ospp:all
    - var_authselect_profile=local

    - '!package_screen_installed'
    - '!package_dnf-plugin-subscription-manager_installed'
    - '!package_scap-security-guide_installed'
    # Currently not working RHEL 10, changes are being made to FIPS mode. Investigation is recommended.
    - '!enable_dracut_fips_module'
    - '!configure_ssh_crypto_policy'
