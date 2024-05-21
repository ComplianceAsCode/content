documentation_complete: true

metadata:
    version: 1.0.0
    SMEs:
        - hipponix

reference: https://www.cisecurity.org/benchmark/amazon_linux/

title: 'CIS Amazon Linux 2023 Benchmark for Level 2 - Server'

description: |-
    This profile defines a baseline that aligns to the "Level 2 - Server"
    configuration from the Center for Internet Security® Amazon Linux
    2023 Benchmark™, v1.0.0, released 2023-06-26.

    This profile includes Center for Internet Security®
    Amazon Linux 2023 CIS Benchmarks™ content.

selections:
    - cis_al2023:all:l2_server
    - '!file_ownership_home_directories'
    - '!group_unique_name'
    - '!file_owner_at_allow'
