documentation_complete: true

metadata:
    version: TBD
    SMEs:
        - jhrozek
        - Vincent056
        - rhmdnd
        - david-rh

reference: https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_Container_Platform_V1R3_SRG.zip

title: '[DRAFT] DISA STIG for Red Hat Enterprise Linux CoreOS'

description: |-
    This is a draft profile for experimental purposes
    It is not based on the DISA STIG for RHCOS4, because this one was not available at time of
    the release

selections:
  - srg_ctr:all
  - var_sshd_set_keepalive=0
  - var_selinux_policy_name=targeted
  - var_selinux_state=enforcing

