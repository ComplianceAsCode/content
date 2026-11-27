---
documentation_complete: true

metadata:
    version: V1R8
    SMEs:
        - sej7278

reference: https://www.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: 'DISA STIG with GUI for AlmaLinux OS 9'

description: |-
    This profile contains configuration checks that align to the
    DISA STIG by Cloud Linux for AlmaLinux OS 9 V1R8.

    Warning: The installation and use of a Graphical User Interface (GUI)
    increases your attack vector and decreases your overall security posture. If
    your Information Systems Security Officer (ISSO) lacks a documented operational
    requirement for a graphical user interface, please consider using the
    standard DISA STIG for AlmaLinux OS 9 profile.

extends: stig

selections:
    # ALMA-09-031040
    - '!xwindows_remove_packages'

    # ALMA-09-014320
    - '!xwindows_runlevel_target'

    # ALMA-09-030600
    - '!package_nfs-utils_removed'

    # locking of idle sessions is handled by screensaver when GUI is present, the following rule is therefore redundant
    - '!logind_session_timeout'
