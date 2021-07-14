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
    ### Rules:
    - accounts_password_pam_lcredit
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_renameat
    - audit_rules_file_deletion_events_rmdir
    - audit_rules_file_deletion_events_unlink
    - audit_rules_file_deletion_events_unlinkat
