---
documentation_complete: true

metadata:
    SMEs:
        - shaneboulden
        - tjbutt58

reference: https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

title: 'Australian Cyber Security Centre (ACSC) Essential Eight'

description: |-
    This profile contains configuration checks for AlmaLinux OS 9
    that align to the Australian Cyber Security Centre (ACSC) Essential Eight.

    A copy of the Essential Eight in Linux Environments guide can be found at the
    ACSC website:

    https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

selections:
    - e8:all
    - '!package_ypbind_removed'
    - '!package_rsh-server_removed'
    - '!package_rsh_removed'
    - package_rear_installed
    - package_audit_installed
    # this package is not available in AlmaLinux OS 9
    - '!package_sequoia-sq_installed'

    # AlmaLinux OS packages are signed with the AlmaLinux key, not the Red Hat one
    - '!ensure_redhat_gpgkey_installed'
    - ensure_almalinux_gpgkey_installed

    # Following rules are not applicable to AlmaLinux OS
    - '!package_talk_removed'
    - '!package_talk-server_removed'
    - '!configure_ssh_crypto_policy'
