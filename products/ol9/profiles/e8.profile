documentation_complete: true

reference: https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

title: 'Australian Cyber Security Centre (ACSC) Essential Eight'

description: |-
  This profile contains configuration checks for Oracle Linux 9
  that align to the Australian Cyber Security Centre (ACSC) Essential Eight.

  A copy of the Essential Eight in Linux Environments guide can be found at the
  ACSC website:

  https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

selections:
    - e8:all
    - '!package_ypbind_removed'
    - '!package_rsh-server_removed'
    - '!package_rsh_removed'
    - 'package_rear_installed'
    - 'package_audit_installed'
    - '!package_sequoia-sq_installed'
    - 'ensure_oracle_gpgkey_installed'

    # Following rules are not applicable to OL
    - '!package_talk_removed'
    - '!package_talk-server_removed'
    - '!ensure_redhat_gpgkey_installed'
