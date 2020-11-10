documentation_complete: true

title: 'Sample Security Profile for Linux-like OSes'

description: |-
    This profile is an sample for use in documentation and example conten.
    The selected rules are standard and should pass quickly on most systems.

selections:
    - file_groupowner_etc_group
    - file_groupowner_etc_gshadow
    - file_groupowner_etc_passwd
    - file_groupowner_etc_shadow
    - file_owner_etc_group
    - file_owner_etc_gshadow
    - file_owner_etc_passwd
    - file_owner_etc_shadow
    - file_permissions_etc_group
    - file_permissions_etc_gshadow
    - file_permissions_etc_passwd
    - file_permissions_etc_shadow
    - no_empty_passwords
    - sshd_disable_root_login
    - sshd_disable_empty_passwords
    - sshd_idle_timeout_value=5_minutes
    - sshd_set_idle_timeout
    - sshd_set_keepalive
