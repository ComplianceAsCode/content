documentation_complete: true

metadata:
    version: V1R4
    SMEs:
        - esampson

reference: 

title: 'Public Cloud SAP Hardening for SUSE Linux Enterprise 15'

description: |-
    This profile contains configuration checks to be used to harden
    SUSE Linux Enterprise 15 SAP Images for use with public cloud providers.

extends: pcs-hardening

selections:
    # remove some rules in pcs-hardening
    - '!accounts_umask_etc_login_defs'
    - '!accounts_umask_etc_profile'
    - '!service_firewalld_enabled'
    - '!sshd_disable_root_login'
    - '!sshd_set_max_auth_tries'
