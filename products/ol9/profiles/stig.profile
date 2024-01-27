documentation_complete: true

metadata:
    version: TBD

reference: https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: 'DRAFT - DISA STIG for Oracle Linux 9'

description: |-
    This is a draft profile based on its OL8 version for experimental purposes.
    It is not based on the DISA STIG for OL9, because this one was not available at time of
    the release.

selections:
  - srg_gpos:all
  - var_accounts_authorized_local_users_regex=ol8
  # Following rules once had a prodtype incompatible with the ol9 product
  - '!package_subscription-manager_installed'
  - '!file_owner_cron_deny'
  - '!package_s-nail_installed'
  - '!networkmanager_dns_mode'
  - '!file_groupowner_cron_deny'
