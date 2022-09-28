documentation_complete: true

metadata:
    version: TBD
    SMEs:
        - mab879
        - ggbecker

reference: https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: '[DRAFT] DISA STIG with GUI for Red Hat Enterprise Linux 9'

description: |-
    This is a draft profile based on its RHEL8 version for experimental purposes.
    It is not based on the DISA STIG for RHEL9, because this one was not available at time of
    the release.

    In addition to being applicable to Red Hat Enterprise Linux 9, DISA recognizes this
    configuration baseline as applicable to the operating system tier of
    Red Hat technologies that are based on Red Hat Enterprise Linux 9, such as:

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

    # RHEL-08-040321
    - '!xwindows_runlevel_target'

    # SRG-OS-000480-GPOS-00227
    - '!package_gdm_removed'
    - '!package_xorg-x11-server-common_removed'
