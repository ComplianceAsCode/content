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
    -  sshd_strong_kex=pcidss
    -  sshd_approved_macs=cis_sle15
    -  sshd_approved_ciphers=cis_sle15 
    -  '!service_ntp_enabled'
    -  '!service_ntpd_enabled'
    -  '!service_timesyncd_enabled'
