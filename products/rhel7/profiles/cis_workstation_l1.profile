documentation_complete: true

metadata:
    version: 4.0.0
    SMEs:
        - vojtapolasek
        - yuumasato

reference: https://www.cisecurity.org/cis-benchmarks/#red_hat_linux


title: 'CIS Red Hat Enterprise Linux 7 Benchmark for Level 1 - Workstation'

description: |-
    This profile defines a baseline that aligns to the "Level 1 - Workstation"
    configuration from the Center for Internet Security® Red Hat Enterprise
    Linux 7 Benchmark™, v4.0.0, released 2023-12-21.

    This profile includes Center for Internet Security®
    Red Hat Enterprise Linux 7 CIS Benchmarks™ content.

selections:
    - cis_rhel7:all:l1_workstation
    # Following rules once had a prodtype incompatible with the rhel7 product
    - '!file_groupowner_at_allow'
    - '!file_permissions_at_allow'
    - '!file_owner_at_allow'
