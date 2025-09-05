documentation_complete: true

metadata:
    SMEs:
        - abergmann

reference: https://docs-prv.pcisecuritystandards.org/PCI%20DSS/Standard/PCI-DSS-v3-2-1-r1.pdf

title: 'PCI-DSS v3.2.1 Control Baseline for SUSE Linux enterprise 12'

description: |-
    Ensures PCI-DSS v3.2.1 security configuration settings are applied.

selections:
    - pcidss_3:all:base
    - sshd_approved_macs=cis_sle12
    - sshd_approved_ciphers=cis_sle12
    - var_multiple_time_servers=suse
    - var_multiple_time_pools=suse 
