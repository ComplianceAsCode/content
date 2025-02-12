documentation_complete: true

metadata:
    version: V2R3
    SMEs:
        - mab879
        - ggbecker

reference: https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: 'DISA STIG for Red Hat Enterprise Linux 9'

description: |-
    This profile contains configuration checks that align to the
    DISA STIG for Red Hat Enterprise Linux 9 V2R3.

    In addition to being applicable to Red Hat Enterprise Linux 9, this
    configuration baseline is applicable to the operating system tier of
    Red Hat technologies that are based on Red Hat Enterprise Linux 9, such as:

    - Red Hat Enterprise Linux Server
    - Red Hat Enterprise Linux Workstation and Desktop
    - Red Hat Enterprise Linux for HPC
    - Red Hat Storage
    - Red Hat Containers with a Red Hat Enterprise Linux 9 image

selections:
  - stig_rhel9:all
  # Following rules once had a prodtype incompatible with the rhel9 product
  - '!audit_rules_immutable_login_uids'
# the following rule causes problems with irqbalance which is present in default RHEL 9 installation, therefore it is not enforced
  - sysctl_user_max_user_namespaces.role=unscored
  - sysctl_user_max_user_namespaces.severity=info
