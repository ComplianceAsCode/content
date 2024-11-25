documentation_complete: true

metadata:
    version: draft
    SMEs:
        - mpurg
        - dodys
        - alanmcanonical

reference: https://www.cisecurity.org/benchmark/ubuntu_linux

title: 'DRAFT - CIS Ubuntu Linux 24.04 LTS Benchmark for Level 2 - Workstation'

description: |-
    This profile defines a baseline that aligns to the "Level 2 - Workstation"
    configuration from the Center for Internet Security® 
    Ubuntu Linux 24.04 LTS Benchmark™, v1.0.0, released 2024-08-26.

    This profile includes Center for Internet Security®
    Ubuntu Linux 24.04 LTS Benchmark™ content.

selections:
    - cis_ubuntu2404:all:l2_workstation
    - '!zipl_audit_argument'
    - '!zipl_audit_backlog_limit_argument'
