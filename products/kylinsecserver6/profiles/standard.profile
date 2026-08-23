documentation_complete: true

metadata:
    version: 1.0

title: 'Standard System Security Profile for KylinSec Server 6'

description: |-
    This profile contains rules to ensure standard security baseline
    of an KylinSec Server 6. Regardless of your system's workload
    all of these checks should pass.

selections:
    - std_kylinsecserver6:all:l2_server
    - std_kylinsecserver6:all:l1_server
