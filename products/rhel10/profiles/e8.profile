documentation_complete: true

metadata:
    SMEs:
        - shaneboulden
        - tjbutt58

reference: https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

title: 'Australian Cyber Security Centre (ACSC) Essential Eight'

description: |-
  This profile contains configuration checks for Red Hat Enterprise Linux 10
  that align to the Australian Cyber Security Centre (ACSC) Essential Eight.

  A copy of the Essential Eight in Linux Environments guide can be found at the
  ACSC website:

  https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

selections:
    - e8:all
    # audit-audispd-plugins package does not exist in RHEL 10 (based on RHEL 9)
    # use only package_audispd-plugins_installed
    - '!package_audit-audispd-plugins_installed'
    # More tests are needed to identify which rule is conflicting with rpm_verify_permissions.
    # https://github.com/ComplianceAsCode/content/issues/11285
    - '!rpm_verify_permissions'
    - '!package_talk_removed'
    - '!package_talk-server_removed'
    - '!package_ypbind_removed'
    - '!package_audit-audispd-plugins_installed'
    - '!set_ipv6_loopback_traffic'
    - '!set_loopback_traffic'
    - '!service_ntpd_enabled'
    - '!package_ypserv_removed'
    - '!package_ypbind_removed'
    - '!package_talk_removed'
    - '!package_talk-server_removed'
    - '!package_xinetd_removed'
    - '!package_rsh_removed'
    - '!package_rsh-server_removed'
