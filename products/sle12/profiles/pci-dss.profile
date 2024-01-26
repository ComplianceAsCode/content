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
# Exclude from PCI DISS profile all rules related to ntp and timesyncd and keep only 
# rules related to chrony
    - '!ntpd_specify_multiple_servers'
    - '!ntpd_specify_remote_server'
    - '!package_ntp_installed'
    - '!service_ntp_enabled'
    - '!service_ntpd_enabled'
    - '!service_timesyncd_enabled'
    - '!package_libreswan_installed'
    # Following rules once had a prodtype incompatible with the sle12 product
    - '!set_firewalld_default_zone'
    - '!accounts_password_pam_dcredit'
    - '!audit_rules_login_events'
    - '!accounts_password_pam_lcredit'
    - '!accounts_passwords_pam_faillock_deny'
    - '!ensure_firewall_rules_for_open_ports'
    - '!accounts_passwords_pam_faillock_unlock_time'
    - '!accounts_password_pam_ucredit'
    - '!accounts_password_pam_minlen'
