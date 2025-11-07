documentation_complete: true

reference: https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

title: 'Australian Cyber Security Centre (ACSC) Essential Eight'

description: |-
    This profile contains configuration checks for {{{ full_name }}}
    that align to the Australian Cyber Security Centre (ACSC) Essential Eight.

    A copy of the Essential Eight in Linux Environments guide can be found at the
    ACSC website:

    https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

selections:
    - e8:all
    - service_xinetd_disabled
    - package_xinetd_removed
    - package_rear_installed
    - '!sshd_use_directory_configuration'

    # Following rules are not applicable to OL
    - '!package_talk_removed'
    - '!package_talk-server_removed'
    - '!ensure_redhat_gpgkey_installed'
    - '!sysctl_kernel_exec_shield'

    - ensure_oracle_gpgkey_installed
