documentation_complete: true

title: 'Standard System Security Profile'

description: |-
    This profile contains rules to ensure standard security baseline
    of Oracle Linux 7 system. Regardless of your system's workload
    all of these checks should pass.

selections:
    - ensure_oracle_gpgkey_installed
    - ensure_gpgcheck_globally_activated
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
