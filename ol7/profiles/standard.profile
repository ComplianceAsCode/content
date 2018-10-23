documentation_complete: true

title: 'Standard System Security Profile for Oracle Linux 7'

description: |-
    This profile contains rules to ensure standard security baseline
    of Oracle Linux 7 system. Regardless of your system's workload
    all of these checks should pass.

selections:
    - ensure_oracle_gpgkey_installed
    - ensure_gpgcheck_globally_activated
    - security_patches_up_to_date
    - rpm_verify_permissions
    - rpm_verify_hashes
    - no_empty_passwords
    - file_permissions_unauthorized_sgid
    - file_permissions_unauthorized_suid
    - file_permissions_unauthorized_world_writable
    - accounts_root_path_dirs_no_write
    - dir_perms_world_writable_sticky_bits
    - root_path_no_dot
    - accounts_password_all_shadowed
    - mount_option_dev_shm_nodev
    - mount_option_dev_shm_nosuid
    - audit_rules_privileged_commands_at
    - audit_rules_privileged_commands_chage
    - audit_rules_privileged_commands_chsh
    - audit_rules_privileged_commands_crontab
    - audit_rules_privileged_commands_gpasswd
    - audit_rules_privileged_commands_mount
    - audit_rules_privileged_commands_newgrp
    - audit_rules_privileged_commands_pam_timestamp_check
    - audit_rules_privileged_commands_passwd
    - audit_rules_privileged_commands_postdrop
    - audit_rules_privileged_commands_postqueue
    - audit_rules_privileged_commands_ssh_keysign
    - audit_rules_privileged_commands_su
    - audit_rules_privileged_commands_sudo
    - audit_rules_privileged_commands_sudoedit
    - audit_rules_privileged_commands_umount
    - audit_rules_privileged_commands_unix_chkpwd
    - audit_rules_privileged_commands_userhelper
    - audit_rules_privileged_commands_usernetctl
