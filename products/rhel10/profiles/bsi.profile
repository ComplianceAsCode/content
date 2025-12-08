documentation_complete: true

title: 'BSI SYS.1.1 and SYS.1.3'

reference: https://www.bsi.bund.de/SharedDocs/Downloads/EN/BSI/Grundschutz/International/bsi_it_gs_comp_2022.pdf

metadata:
    SMEs:
        - sluetze
    version: 2022

description: |-
    This profile defines a baseline that aligns to the BSI (Federal Office for Security Information) IT-Grundschutz
    Basic-Protection.

    This baseline implements OS-Level configuration requirements from the following
    sources:

    - Building-Block SYS.1.1 General Server
    - Building-Block SYS.1.3 Linux Server

selections:
    - bsi_sys_1_1_rhel10:all
    - bsi_sys_1_3_rhel10:all

    # BSI APP.4.4.A4
    - var_selinux_policy_name=targeted
    - var_selinux_state=enforcing
