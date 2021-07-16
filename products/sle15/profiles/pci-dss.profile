documentation_complete: true

metadata:
    SMEs:
        - abergmann

reference: https://www.pcisecuritystandards.org/documents/PCI_DSS_v3-2-1.pdf

title: 'PCI-DSS v3.2.1 Control Baseline for SUSE Linux enterprise 15'

description: |-
    Ensures PCI-DSS v3.2.1 security configuration settings are applied.

selections:
    ### Variables
    - var_password_pam_lcredit=1
    - var_accounts_passwords_pam_faillock_deny=6
    - var_accounts_passwords_pam_faillock_unlock_time=1800
    ### Rules:
    - accounts_password_pam_lcredit
    - accounts_password_pam_unix_remember
    - accounts_passwords_pam_faillock_deny
    - accounts_passwords_pam_faillock_unlock_time
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_renameat
    - audit_rules_file_deletion_events_rmdir
    - audit_rules_file_deletion_events_unlink
    - audit_rules_file_deletion_events_unlinkat
    - display_login_attempts

