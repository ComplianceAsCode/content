documentation_complete: true

metadata:
    version: V1R3

title: 'DISA STIG with GUI for Oracle Linux 8'

description: |-
    This profile contains configuration checks that align to the
    DISA STIG with GUI for Oracle Linux V1R3.

    Warning: The installation and use of a Graphical User Interface (GUI)
    increases your attack vector and decreases your overall security posture. If
    your Information Systems Security Officer (ISSO) lacks a documented operational
    requirement for a graphical user interface, please consider using the
    standard DISA STIG for Oracle Linux 8 profile.

extends: stig

selections:
    - '!xwindows_remove_packages'
    - '!xwindows_runlevel_target'
