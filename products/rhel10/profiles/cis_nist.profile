documentation_complete: true
metadata:
  version: 1.0.1
  SMEs:
    - nist_sync_automation
reference: https://www.cisecurity.org/benchmark/red_hat_linux/
title: CIS Red Hat Enterprise Linux 10 Benchmark for Level 2 - Server (NIST-based)
description: "This profile defines a baseline that aligns to the \"Level 2 - Server\"\nconfiguration from the Center for Internet Security® Red Hat Enterprise\nLinux 10 Benchmark™, v1.0.1.\n\nThis profile is generated from the NIST 800-53 control file and uses\nthe unified NIST 800-53 controls that include CIS-derived rules and\nvariables from all RHEL versions.\n\nThis profile includes Center for Internet Security®\nRed Hat Enterprise Linux 10 CIS Benchmarks™ content."
selections:
  - nist_800_53:all
  - var_authselect_profile=local
