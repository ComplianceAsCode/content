documentation_complete: false

title: '[DRAFT] DISA STIG for Red Hat Enterprise Linux 8'

description: |-
    Placeholder to put DISA controls

extends: ospp

selections:

    ## IA-5(1)(d) / CCI-000198 / SRG-OS-000075-GPOS-00043
    - var_accounts_minimum_age_login_defs=1
    - accounts_minimum_age_login_defs
    - accounts_password_set_min_life_existing

    ## IA-5(1)(d) / CCI-000199 / SRG-OS-000076-GPOS-00044
    - var_accounts_maximum_age_login_defs=60
    - accounts_maximum_age_login_defs
    - accounts_password_set_max_life_existing
