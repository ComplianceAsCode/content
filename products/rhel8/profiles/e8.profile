documentation_complete: true

metadata:
    SMEs:
        - shaneboulden
        - tjbutt58

reference: https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

title: 'Australian Cyber Security Centre (ACSC) Essential Eight'

description: |-
  This profile contains configuration checks for Red Hat Enterprise Linux 8
  that align to the Australian Cyber Security Centre (ACSC) Essential Eight.

  A copy of the Essential Eight in Linux Environments guide can be found at the
  ACSC website:

  https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

selections:
    - e8:all
    - service_xinetd_disabled
    - package_xinetd_removed
    - package_rear_installed
    - '!package_rsh_removed'
    - '!sshd_use_directory_configuration'
    - '!package_rsh-server_removed'

    # Following rules are not applicable to RHEL
    - '!package_talk_removed'
    - '!package_talk-server_removed'
