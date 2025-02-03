documentation_complete: true

reference: https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

title: 'DRAFT - Australian Cyber Security Centre (ACSC) Essential Eight'

description: |-
    This is a draft profile for experimental purposes.

    This draft profile contains configuration checks for Oracle Linux 10
    that align to the Australian Cyber Security Centre (ACSC) Essential Eight.

    A copy of the Essential Eight in Linux Environments guide can be found at the
    ACSC website:

    https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

selections:
    - e8:all

    - '!ensure_redhat_gpgkey_installed'
    - '!ensure_almalinux_gpgkey_installed'
    - ensure_oracle_gpgkey_installed

    - var_system_crypto_policy=default_policy
    # these packages do not exist in OL 10
    - '!package_talk_removed'
    - '!package_talk-server_removed'
    - '!package_ypbind_removed'
    - '!package_ypserv_removed'
    - '!package_rsh_removed'
    - '!package_rsh-server_removed'
    - '!security_patches_up_to_date'
