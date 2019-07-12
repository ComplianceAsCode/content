documentation_complete: true

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

    # ==============================================
    # R11 - IOMMU Configuration Guidelines
    # The iommu = force directive must be added to the list of kernel parameters
    # during startup in addition to those already present in the configuration
    # files of the bootloader (/boot/grub/menu.lst or  /etc/default/grub).
    - grub2_enable_iommu_force

    # ==============================================
    # R67 - Setting SELinux booleans
    # It is recommended to set the following Boolean values to ​​off:
    # allow_execheap        if off, forbid processes to make their heap executable (heap);
    # allow_execmem         if off, forbid processes to have a memory area with rights w (write) and x (execute);
    # allow_execstack       if off, forbid processes to make their stack (stack) executable;

    # secure_mode_insmod    if off, prohibits dynamic loading of modules by any process;
    - sebool_secure_mode_insmod

    # ssh_sysadm_login      if off, forbid SSH logins to connect directly in sysadmin role.
    - sebool_ssh_sysadm_login
