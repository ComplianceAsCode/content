documentation_complete: true

metadata:
    version: V1R1

reference: https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: 'DISA STIG with GUI for Oracle Linux 9'

description: |-
    This profile contains configuration checks that align to the
    DISA STIG for Oracle Linux 9 V1R1.

    Warning: The installation and use of a Graphical User Interface (GUI)
    increases your attack vector and decreases your overall security posture. If
    your Information Systems Security Officer (ISSO) lacks a documented operational
    requirement for a graphical user interface, please consider using the
    standard DISA STIG for Oracle Linux 9 profile.

extends: stig

selections:
    # Unselect rules that remove packages required by "server with GUI" installation
    # OL09-00-000145
    - '!xwindows_remove_packages'
    # OL09-00-000100
    - '!package_nfs-utils_removed'
    # OL09-00-000020
    - '!xwindows_runlevel_target'
