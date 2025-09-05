documentation_complete: true

title: 'DRAFT - BSI APP.4.4. and SYS.1.6'

description: |-
    This profile defines a baseline that aligns to the BSI (Federal Office for Security Information) IT-Grundschutz
    Basic-Protection.

    This baseline implements OS-Level configuration requirements from the following
    sources:

    - Building-Block SYS.1.6 Containerisation
    - Building-Block APP.4.4 Kubernetes

    THIS DOES NOT INCLUDE REQUIREMENTS FOR A HARDENED LINUX FROM SYS.1.3 LINUX

selections:
    # BSI APP.4.4.A4
    - coreos_enable_selinux_kernel_argument
    - var_selinux_policy_name=targeted
    - selinux_policytype
    - var_selinux_state=enforcing
    - selinux_state
