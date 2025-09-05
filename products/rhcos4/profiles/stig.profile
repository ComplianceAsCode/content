documentation_complete: true

metadata:
    version: V1R1
    SMEs:
        - jhrozek
        - Vincent056
        - rhmdnd
        - david-rh

reference: https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_Container_Platform_V1R3_SRG.zip

title: 'DISA STIG for Red Hat Enterprise Linux CoreOS'

description: |-
    This profile contains configuration checks that align to the DISA STIG for
    Red Hat Enterprise Linux CoreOS 4.

selections:
  - srg_ctr:all
  - var_sshd_set_keepalive=0
  - var_selinux_policy_name=targeted
  - var_selinux_state=enforcing
  # Let's mark the vsyscall argument as info - the check and the fix is there, but setting this
  # karg is not suitable for people who still run legacy 32bit apps.
  - coreos_vsyscall_kernel_argument.role=unscored
  - coreos_vsyscall_kernel_argument.severity=info
