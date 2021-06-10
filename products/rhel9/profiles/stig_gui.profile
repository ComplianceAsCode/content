documentation_complete: true

metadata:
    version: NA
    SMEs:
        - carlosmmatos

reference: https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: '[DRAFT] DISA STIG with GUI for Red Hat Enterprise Linux 9'

description: |-
    This profile contains configuration checks that are based on the RHEL8 STIG

    In addition to being applicable to Red Hat Enterprise Linux 9, DISA recognizes this
    configuration baseline as applicable to the operating system tier of
    Red Hat technologies that are based on Red Hat Enterprise Linux 8, such as:

    - Red Hat Enterprise Linux Server
    - Red Hat Enterprise Linux Workstation and Desktop
    - Red Hat Enterprise Linux for HPC
    - Red Hat Storage
    - Red Hat Containers with a Red Hat Enterprise Linux 9 image

    Warning: The installation and use of a Graphical User Interface (GUI)
    increases your attack vector and decreases your overall security posture. If
    your Information Systems Security Officer (ISSO) lacks a documented operational
    requirement for a graphical user interface, please consider using the
    standard DISA STIG for Red Hat Enterprise Linux 9 profile.

extends: stig

selections:
    # RHEL-08-040320
    - '!xwindows_remove_packages'
