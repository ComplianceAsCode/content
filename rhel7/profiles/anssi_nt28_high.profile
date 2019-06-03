# Don't forget to enable build of tables in rhel7CMakeLists.txt when setting to true
documentation_complete: false

title: 'DRAFT - ANSSI DAT-NT28 (high)'

description: 'Draft profile for ANSSI compliance at the high level. ANSSI stands for Agence nationale de la sécurité des systèmes
    d''information. Based on https://www.ssi.gouv.fr/.'

extends: anssi_nt28_enhanced

selections:
    - var_selinux_policy_name=targeted
    - selinux_policytype
    - package_setroubleshoot_removed
    - package_aide_installed
    - aide_periodic_cron_checking
    - aide_scan_notification
    - aide_verify_acls
    - aide_verify_ext_attributes
