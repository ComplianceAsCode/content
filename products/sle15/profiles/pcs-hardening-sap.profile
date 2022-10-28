documentation_complete: true

metadata:
    version: V1R4
    SMEs:
        - esampson

reference: 

title: 'Hardening for Public Cloud Image of SUSE Linux Enterprise Server (SLES) for SAP Applications 15'

description: |-
    This profile contains configuration rules to be used to harden the images
    of SUSE Linux Enterprise Server (SLES) for SAP Applications 15 including
    all Service Packs, for Public Cloud providers, currently AWS, Microsoft
    Azure, and Google Cloud.

extends: pcs-hardening

selections:
    # Install rules for we want for SAP
    - install_smartcard_packages
    - package_aide_installed
    - package_audit-audispd-plugins_installed
    - package_audit_installed
    - package_chrony_installed
    - package_iptables_installed
    - package_rsyslog_installed
    # remove some rules in pcs-hardening
    - '!accounts_umask_etc_login_defs'
    - '!accounts_umask_etc_profile'
    - '!service_firewalld_enabled'
    - '!sshd_disable_root_login'
    - '!sshd_set_max_auth_tries'
