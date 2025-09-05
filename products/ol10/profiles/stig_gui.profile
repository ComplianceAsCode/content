documentation_complete: true

metadata:
    SMEs:
        - mab879


reference: https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: 'DRAFT - DISA STIG for Oracle Linux 10'

description: |-
    This is a draft profile for experimental purposes.
    It is not based on the DISA STIG for OL 10, because it was not available at time of
    the release.

extends: stig

selections:
    - '!xwindows_remove_packages'

    - '!xwindows_runlevel_target'

    - '!package_nfs-utils_removed'

    # Limiting user namespaces cause issues with user apps, such as Firefox and Cheese
    - '!sysctl_user_max_user_namespaces'
    # locking of idle sessions is handled by screensaver when GUI is present, the following rule is therefore redundant
    - '!logind_session_timeout'
