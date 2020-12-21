documentation_complete: true

title: 'DISA STIG for SUSE Linux Enterprise 12'

description: |-
    This profile contains configuration checks that align to the
    DISA STIG for SUSE Linux Enterprise 12 V1R2.

selections:
    - installed_OS_is_vendor_supported
    - security_patches_up_to_date
    - sudo_remove_nopasswd
    - sudo_remove_no_authenticate
    - sshd_disable_empty_passwords
    - sshd_do_not_permit_user_env
    - gnome_gdm_disable_automatic_login
