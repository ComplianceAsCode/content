documentation_complete: true

metadata:
    version: 2.0.0
    SMEs:
        - sej7278

reference: https://www.cisecurity.org/benchmark/almalinuxos_linux/

title: 'CIS AlmaLinux OS 9 Benchmark for Level 1 - Server'

description: |-
    This profile defines a baseline that aligns to the "Level 1 - Server"
    configuration from the Center for Internet Security® AlmaLinux OS 9 
    Benchmark™, v2.0.0, released 2024-06-20.

    This profile includes Center for Internet Security®
    AlmaLinux OS 9 CIS Benchmarks™ content.

selections:
    - cis_almalinux9:all:l1_server
    - '!file_ownership_home_directories'
    - '!group_unique_name'
    - '!file_owner_at_allow'
