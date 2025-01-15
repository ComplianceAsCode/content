documentation_complete: true

reference: https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: 'DRAFT - DISA STIG for Oracle Linux 10'

description: |-
    This is a draft profile for experimental purposes.
    It is not based on the DISA STIG for OL 10, because it was not available at time of
    the release.

selections:
    - srg_gpos:all
    - var_accounts_authorized_local_users_regex=ol9
    - '!enable_dracut_fips_module'
    # Package not available in OL10
    - '!package_subscription-manager_installed'
