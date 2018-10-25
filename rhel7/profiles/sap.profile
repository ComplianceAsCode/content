documentation_complete: true

title: 'SAP Security Baseline Template V1.9 - Operating System Security'

description: |-
    This profile contains rules for compliance with SAP note 2069760 and SAP
    Security Baseline Template version 1.9 Item I-8 and section 4.1.2.2 for
    unix systems.
    
selections:
    - package_glibc_installed
    - package_uuidd_installed
    - file_permissions_etc_passwd
    - file_permissions_etc_shadow
    - service_rlogin_disabled
    - service_rsh_disabled
    - no_rsh_trust_files
    - package_ypbind_removed
    - package_ypserv_removed
    - no_host_based_files
    - no_user_host_based_files
    - disable_host_auth
    - sshd_disable_rhosts
    - service_sshd_enabled
    - security_patches_up_to_date
    - var_accounts_authorized_local_users_regex=ol7forsap
    - accounts_authorized_local_users_sidadm_orasid
