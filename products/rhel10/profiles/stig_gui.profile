---
documentation_complete: true

metadata:
    version: V1R1
    SMEs:
        - mab879

reference: https://www.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: 'Red Hat STIG with GUI for Red Hat Enterprise Linux 10'

description: >-
    This profile contains configuration checks that align to the
    DISA STIG for Red Hat Enterprise Linux 10 V1R1.

    In addition to being applicable to Red Hat Enterprise Linux 10, this
    configuration baseline is applicable to the operating system tier of
    Red Hat technologies that are based on Red Hat Enterprise Linux 10.

    Warning: The installation and use of a Graphical User Interface (GUI)
    increases your attack vector and decreases your overall security posture. If
    your Information Systems Security Officer (ISSO) lacks a documented operational
    requirement for a graphical user interface, please consider using the
    standard DISA STIG for Red Hat Enterprise Linux 10 profile.

extends: stig

selections:
    - '!xwindows_runlevel_target'
    - '!package_nfs-utils_removed'
    # Package gdm cannot be removed as it is required for GUI installation ('@Server with GUI' package group)
    - '!package_gdm_removed'
