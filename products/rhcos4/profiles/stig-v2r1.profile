documentation_complete: true

status: deprecated
metadata:
    version: V2R1
    SMEs:
        - Vincent056
        - rhmdnd
        - yuumasato

reference: https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_RH_OpenShift_Container_Platform_4-12_V2R1_STIG.zip

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
  # Following rules once had a prodtype incompatible with the rhcos4 product
  - '!audit_rules_suid_privilege_function'
  - '!audit_rules_sudoers'
  - '!audit_rules_privileged_commands_kmod'
  - '!audit_rules_sudoers_d'
  - '!audit_rules_execution_setfacl'
  - '!audit_rules_privileged_commands_usermod'
  - '!audit_rules_privileged_commands_unix_update'
  - '!audit_rules_execution_chacl'
  - '!audit_rules_privileged_commands_ssh_agent'
