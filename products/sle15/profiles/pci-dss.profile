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
    - sshd_approved_macs=cis_sle15
    - sshd_approved_ciphers=cis_sle15
    - var_multiple_time_servers=suse
    - var_multiple_time_pools=suse    
# Exclude from PCI DISS profile all rules related to ntp and timesyncd and keep only 
# rules related to chrony
    - '!ntpd_specify_multiple_servers'
    - '!ntpd_specify_remote_server'
    - '!package_ntp_installed'
    - '!service_ntp_enabled'
    - '!service_ntpd_enabled'
    - '!service_timesyncd_enabled'
    - '!package_libreswan_installed'
