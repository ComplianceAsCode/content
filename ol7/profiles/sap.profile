documentation_complete: true

title: 'Security Profile of Oracle Linux 7 for SAP'

description: |-
    This profile contains rules for Oracle Linux 7 Operating System
    in compliance with SAP note 2069760 and SAP Security Baseline v1.9
    Item I-8 and section 4.1.2.2. Regardless of your system's workload
    all of these checks should pass.
    
selections:
    - package_glibc_installed
    - package_uuidd_installed
    - file_permissions_etc_shadow
    - service_rlogin_disabled
    - service_rsh_disabled
    - no_rsh_trust_files
