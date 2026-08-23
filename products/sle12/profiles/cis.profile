documentation_complete: true

metadata:
    version: 1.1.0
    SMEs:
        - truzzon
        - rumch-se

reference: https://www.cisecurity.org/cis-benchmarks/#suse_linux


title: 'CIS SUSE Linux Enterprise 12 Benchmark for Level 2 - Server'

description: |-
    This profile defines a baseline that aligns to the "Level 2 - Server"
    configuration from the Center for Internet Security®
    SUSE Linux Enterprise 12 Benchmark™, v3.1.0, released 01-24-2022.

    This profile includes Center for Internet Security®
    SUSE Linux Enterprise 12 CIS Benchmarks™ content.

selections:
    - cis_sle12:all:l2_server
    # Exclude from CIS profile all rules related to ntp and timesyncd and keep only
    # rules related to chrony
    - '!ntpd_configure_restrictions'
    - '!ntpd_run_as_ntp_user'
    - '!ntpd_specify_remote_server'
    - '!service_ntpd_enabled'
    - '!service_timesyncd_enabled'
    - '!service_timesyncd_configured'
