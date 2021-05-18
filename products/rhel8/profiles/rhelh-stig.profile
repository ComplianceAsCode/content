documentation_complete: true

title: '[DRAFT] DISA STIG for Red Hat Enterprise Linux Virtualization Host (RHELH)'

description: |-
    This *draft* profile contains configuration checks that align to the
    DISA STIG for Red Hat Enterprise Linux Virtualization Host (RHELH).

extends: stig

selections:
    - sudo_vdsm_nopasswd
    - package_gdm_removed
