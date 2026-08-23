documentation_complete: false

title: 'Standard System Security Profile for AlmaLinux OS 9'

description: |-
    This profile contains rules to ensure standard security baseline
    of an AlmaLinux OS 9 system. Regardless of your system's workload
    all of these checks should pass.

selections:
    - sshd_disable_root_login
    - ensure_almalinux_gpgkey_installed
    - ensure_gpgcheck_globally_activated
    - ensure_gpgcheck_never_disabled
    - rpm_verify_permissions
    - security_patches_up_to_date
