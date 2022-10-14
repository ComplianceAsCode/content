title: Protection Profile for General Purpose Operating Systems
description: 'This profile is part of Red Hat Enterprise Linux 9 Common Criteria Guidance

    documentation for Target of Evaluation based on Protection Profile for

    General Purpose Operating Systems (OSPP) version 4.2.1 and Functional

    Package for SSH version 1.0.


    Where appropriate, CNSSI 1253 or DoD-specific values are used for

    configuration, based on Configuration Annex to the OSPP.'
extends: null
metadata:
    version: 4.2.1
    SMEs:
    - comps
    - stevegrubb
reference: https://www.niap-ccevs.org/Profile/Info.cfm?PPID=442&id=442
selections:
- accounts_password_pam_dcredit
- accounts_password_pam_dcredit.severity=info
- var_password_pam_dcredit=1
unselected_groups: []
platforms: !!set {}
cpe_names: !!set {}
platform: null
filter_rules: ''
documentation_complete: true
