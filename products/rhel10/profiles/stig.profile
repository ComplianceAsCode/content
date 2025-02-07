documentation_complete: true

metadata:
    SMEs:
        - mab879


reference: https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: 'Red Hat STIG for Red Hat Enterprise Linux 10'

description: |-
    This is a profile based on what is expected in the RHEL 10 STIG.
    It is not based on the DISA STIG for RHEL 10, because it was not available at time of
    the release.

    In addition to being applicable to Red Hat Enterprise Linux 10, this
    configuration baseline is applicable to the operating system tier of
    Red Hat technologies that are based on Red Hat Enterprise Linux 10.

selections:
    - srg_gpos:all
    # Currently not working RHEL 10, changes are being made to FIPS mode. Investigation is recommended.
    - '!enable_dracut_fips_module'
