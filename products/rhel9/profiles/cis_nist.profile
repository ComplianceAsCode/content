documentation_complete: true
metadata:
  version: 2.0.0
  SMEs:
    - nist_sync_automation
reference: https://www.cisecurity.org/benchmark/red_hat_linux/
title: CIS Red Hat Enterprise Linux 9 Benchmark for Level 2 - Server (NIST-based)
description: "This profile defines a baseline that aligns to the \"Level 2 - Server\"\nconfiguration from the Center for Internet Security® Red Hat Enterprise\nLinux 9 Benchmark™, v2.0.0.\n\nThis profile is generated from the NIST 800-53 control file and uses\nthe unified NIST 800-53 controls that include CIS-derived rules and\nvariables from all RHEL versions.\n\nThis profile includes Center for Internet Security®\nRed Hat Enterprise Linux 9 CIS Benchmarks™ content."
selections:
  - nist_800_53:all
  - '!file_ownership_home_directories'
  - '!group_unique_name'
  - '!file_owner_at_allow'
