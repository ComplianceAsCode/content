documentation_complete: true

metadata:
    version: draft
    SMEs:
        - blasci

reference: https://www.cisecurity.org/benchmark/debian_linux

title: 'DRAFT - CIS Debian Linux 12 Benchmark for Level 1 - Server'

description: |-
    This profile defines a baseline that aligns to the "Level 1 - Server"
    configuration from the Center for Internet Security® 
    Debian Linux 12 Benchmark™, v1.1.0, released 2024-09-26.

    This profile includes Center for Internet Security®
    Debian Linux 12 Benchmark™ content.

selections:
    - cis_debian12:all:l1_server
    # Define default firewall
    - var_network_filtering_service=nftables
    # Define default ntp service
    - var_timesync_service=systemd-timesyncd
    