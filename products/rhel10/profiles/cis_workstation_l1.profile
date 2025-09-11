---
documentation_complete: true

metadata:
    version: 1.0.0
    SMEs:
        - mab879
        - ggbecker

reference: https://www.cisecurity.org/benchmark/red_hat_linux/

title: 'CIS Red Hat Enterprise Linux 10 Benchmark for Level 1 - Workstation'

description: |-
    This profile defines a baseline that aligns to the "Level 1 - Workstation"
    configuration from the Center for Internet Security® Red Hat Enterprise
    Linux 10 Benchmark™, v1.0.0, released 2025-08-27.

    This profile includes Center for Internet Security®
    Red Hat Enterprise Linux 10 CIS Benchmarks™ content.

selections:
    - cis_rhel10:all:l1_workstation
    - var_authselect_profile=local
