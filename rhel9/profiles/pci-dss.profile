documentation_complete: true

metadata:
    SMEs:
        - carlosmmatos

reference: https://www.pcisecuritystandards.org/documents/PCI_DSS_v3-2-1.pdf

title: 'PCI-DSS v3.2.1 Control Baseline for Red Hat Enterprise Linux 9'

description: |-
    Ensures PCI-DSS v3.2.1 security configuration settings are applied.

selections:
    # selections are empty because almost no rules are applicable for RHEL9
    - package_rsyslog_installed
    - rsyslog_files_permissions
    - rsyslog_files_ownership
    - rsyslog_files_groupownership
