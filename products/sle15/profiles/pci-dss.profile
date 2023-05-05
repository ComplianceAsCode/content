documentation_complete: true

metadata:
    SMEs:
        - abergmann

reference: https://www.pcisecuritystandards.org/documents/PCI_DSS_v3-2-1.pdf

title: 'PCI-DSS v3.2.1 Control Baseline for SUSE Linux enterprise 15'

description: |-
    Ensures PCI-DSS v3.2.1 security configuration settings are applied.

selections:
    - pcidss_3:all:base
    # remove some rules from profile
    - '!accounts_passwords_pam_faillock_deny'
    - '!accounts_passwords_pam_faillock_deny_root'
    - '!accounts_passwords_pam_faillock_unlock_time'
