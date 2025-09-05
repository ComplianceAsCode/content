documentation_complete: true

title: 'ANSSI BP-028 (high)'

description: 
    ANSSI BP-028 compliance at the high level. ANSSI stands for
    Agence nationale de la sécurité des systèmes d'information. Based on
    https://www.ssi.gouv.fr/.

extends: anssi_bp28_enhanced

selections:
    # Using access control features
    - selinux_state
    - var_selinux_state=enforcing

    # IOMMU Configuration Guidelines

    # Partitioning the syslog service by container

    # Sealing and integrity of files
    - package_aide_installed
    - aide_build_database
    - aide_periodic_cron_checking
    - aide_scan_notification
    - aide_verify_acls
    - aide_verify_ext_attributes

    # Enabling SELinux Targeted Policy
    - selinux_policytype
    - var_selinux_policy_name=targeted

    # Setting SELinux booleans
    - sebool_selinuxuser_execheap
    - sebool_cups_execmem
    - sebool_httpd_execmem
    - sebool_boinc_execmem
    - sebool_xserver_execmem
    - sebool_deny_execmem
    - sebool_cluster_use_execmem
    - sebool_glance_use_execmem
    - sebool_virt_use_execmem
    - sebool_selinuxuser_execstack
    - sebool_secure_mode_insmod
    - sebool_ssh_sysadm_login

    # Uninstalling SELinux Policy Debugging Tools
    - package_setroubleshoot_removed

