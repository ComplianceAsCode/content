documentation_complete: true

metadata:
    SMEs:
        - abergmann

reference: https://docs-prv.pcisecuritystandards.org/PCI%20DSS/Standard/PCI-DSS-v4_0.pdf

title: 'PCI-DSS v4 Control Baseline for SUSE Linux enterprise 15'

description: |-
    Ensures PCI-DSS v4 security configuration settings are applied.

selections:
    -  pcidss_4:all:base
    # remove some rules from profile
    - '!service_ntp_enabled'
    - '!service_ntpd_enabled'
    - '!service_timesyncd_enabled'
