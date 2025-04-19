documentation_complete: true

metadata:
    version: V2R2
    SMEs:
        - Vincent056
        - rhmdnd
        - yuumasato

reference: https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_RH_OpenShift_Container_Platform_4-12_V2R2_STIG.zip

title: 'DISA STIG for Red Hat Enterprise Linux CoreOS'

description: |-
    This profile contains configuration checks that align to the DISA STIG for
    Red Hat Enterprise Linux CoreOS 4.

selections:
  - stig_ocp4:all
  - var_sshd_set_keepalive=0
  - var_selinux_policy_name=targeted
  - var_selinux_state=enforcing
  - var_accounts_passwords_pam_faillock_dir=run
