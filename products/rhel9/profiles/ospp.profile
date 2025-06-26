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
    This profile is part of Red Hat Enterprise Linux 9 Common Criteria Guidance
    documentation for Target of Evaluation based on Protection Profile for
    General Purpose Operating Systems (OSPP) version 4.3 and Functional
    Package for SSH version 1.0.

    Where appropriate, CNSSI 1253 or DoD-specific values are used for
    configuration, based on Configuration Annex to the OSPP.

selections:
    - ospp:all
    - enable_authselect
    - var_authselect_profile=minimal
    - '!package_dnf-plugin-subscription-manager_installed'
