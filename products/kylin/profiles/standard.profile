documentation_complete: true

metadata:
    version: 1.0

title: 'Standard System Security Profile for Kylin OS'

description: |-
    This profile contains rules to ensure standard security baseline
    of an Kylin system. Regardless of your system's workload
    all of these checks should pass.

selections:
    - std_kylin:all:l2_server
    - std_kylin:all:l1_server
