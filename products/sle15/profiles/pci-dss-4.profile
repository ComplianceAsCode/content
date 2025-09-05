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
    -  ensure_pam_wheel_group_empty
    -  sshd_strong_kex=pcidss
    -  sshd_approved_macs=cis_sle15
    -  sshd_approved_ciphers=cis_sle15 
    -  var_multiple_time_servers=suse
    -  var_multiple_time_pools=suse      
# Exclude from PCI DISS profile all rules related to ntp and timesyncd and keep only 
# rules related to chrony
    - '!ntpd_specify_multiple_servers'
    - '!ntpd_specify_remote_server'
    - '!service_ntp_enabled'
    - '!service_ntpd_enabled'
    - '!service_timesyncd_enabled'
    - '!package_libreswan_installed'
    - '!use_pam_wheel_for_su'
    -  use_pam_wheel_group_for_su
    -  var_pam_wheel_group_for_su=cis
