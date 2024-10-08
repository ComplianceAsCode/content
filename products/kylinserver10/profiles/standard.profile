documentation_complete: true

metadata:
    version: 1.0

title: 'Standard System Security Profile for Kylin Server V10'

description: |-
    This profile contains rules to ensure standard security baseline
    of an Kylin Server V10. Regardless of your system's workload
    all of these checks should pass.

selections:
    - std_kylinserver10:all:l2_server
    - std_kylinserver10:all:l1_server
