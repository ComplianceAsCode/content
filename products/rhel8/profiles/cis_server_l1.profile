documentation_complete: true

metadata:
    version: 2.0.0
    SMEs:
        - marcusburghardt
        - vojtapolasek
        - yuumasato

reference: https://www.cisecurity.org/benchmark/red_hat_linux/

title: 'CIS Red Hat Enterprise Linux 8 Benchmark for Level 1 - Server'

description: |-
    This profile defines a baseline that aligns to the "Level 1 - Server"
    configuration from the Center for Internet Security® Red Hat Enterprise
    Linux 8 Benchmark™, v2.0.0, released 2022-02-23.

    This profile includes Center for Internet Security®
    Red Hat Enterprise Linux 8 CIS Benchmarks™ content.

selections:
    - cis_rhel8:all:l1_server
    # Following rules once had a prodtype incompatible with the rhel8 product
    - '!file_owner_at_allow'
    - '!package_dnsmasq_removed'
