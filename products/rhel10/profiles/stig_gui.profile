documentation_complete: true

metadata:
    SMEs:
        - mab879


reference: https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: 'DRAFT - DISA STIG for Red Hat Enterprise Linux 10'

description: |-
    This is a draft profile for experimental purposes.
    It is not based on the DISA STIG for RHEL 10, because it was not available at time of
    the release.

    In addition to being applicable to Red Hat Enterprise Linux 10, DISA recognizes this
    configuration baseline as applicable to the operating system tier of
    Red Hat technologies that are based on Red Hat Enterprise Linux 10.

extends: stig

selections:
    - '!xwindows_remove_packages'

    - '!xwindows_runlevel_target'

    - '!package_nfs-utils_removed'

    # Limiting user namespaces cause issues with user apps, such as Firefox and Cheese
    # https://issues.redhat.com/browse/RHEL-10416
    - '!sysctl_user_max_user_namespaces'
