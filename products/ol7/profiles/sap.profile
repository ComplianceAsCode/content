documentation_complete: true

title: 'Security Profile of Oracle Linux 7 for SAP'

description: |-
    This profile contains rules for Oracle Linux 7 Operating System in compliance with SAP note 2069760 and SAP Security Baseline Template version 1.9 Item I-8 and section 4.1.2.2.
    Regardless of your system's workload all of these checks should pass.

selections:
    - package_glibc_installed
    - package_uuidd_installed
    - file_permissions_etc_shadow
    - service_rlogin_disabled
    - service_rsh_disabled
    - no_rsh_trust_files
    - package_ypbind_removed
    - package_ypserv_removed
    - var_accounts_authorized_local_users_regex=ol7forsap
    - accounts_authorized_local_users_sidadm_orasid
