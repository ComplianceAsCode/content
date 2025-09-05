documentation_complete: true

title: 'DRAFT - ANSSI DAT-NT28 (high)'

description: 'Draft profile for ANSSI compliance at the high level. ANSSI stands for Agence nationale de la sécurité des systèmes
    d''information. Based on https://www.ssi.gouv.fr/.'

extends: anssi_nt28_enhanced

selections:
    # ==============================================
    # R4 - Using access control features
    # It is recommended to use the mandatory access control (MAC) features in
    # addition to the traditional Unix user model (DAC), or possibly combine
    # them with partitioning mechanisms.
    - selinux_state
    - var_selinux_state=enforcing

    # ==============================================
    # R11 - IOMMU Configuration Guidelines
    # The iommu = force directive must be added to the list of kernel parameters
    # during startup in addition to those already present in the configuration
    # files of the bootloader (/boot/grub/menu.lst or  /etc/default/grub).
    - grub2_enable_iommu_force

    # ==============================================
    # R45 - Partitioning the syslog service by container
    # The syslog services must be isolated from the rest of the system in a
    # dedicated container.

    # ==============================================
    # R51 - Sealing and integrity of files
    # Any file that is not transient (such as temporary files, databases, etc.)
    # must be monitored by a sealing program.
    # This includes: directories containing executables, libraries,
    # configuration files, as well as any files that may contain sensitive
    # elements (cryptographic keys, passwords, confidential data).
    - package_aide_installed
    - aide_build_database
    - aide_periodic_cron_checking
    - aide_scan_notification
    - aide_verify_acls
    - aide_verify_ext_attributes

    # ==============================================
    # R52 - Protection of the seals database
    # The sealing database must be protected from malicious access by
    # cryptographic signature mechanisms (with the key used for the signature
    # not locally stored in clear), or possibly stored on a separate machine
    # of the one on which the sealing is done.
    # Check section "Database and config signing in AIDE manual
    # https://github.com/aide/aide/blob/master/doc/manual.html

    # ==============================================
    # R65 - Enable AppArmor security profiles
    # All AppArmor security profiles on the system must be enabled by default.

    # ==============================================
    # R66 - Enabling SELinux Targeted Policy
    # It is recommended to enable the targeted policy when the distribution
    # support it and that it does not operate another security module than SELinux.
    - selinux_policytype
    - var_selinux_policy_name=targeted

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

    # ==============================================
    # R68 - Uninstalling SELinux Policy Debugging Tools
    # SELinux policy manipulation and debugging tools should not be installed
    # on a machine in production.
    - package_setroubleshoot_removed

    # ==============================================
    # R69 - Kernel hardening with grsecurity
    # It is recommended to use a hardened kernel with grsecurity patch when
    # the GNU/Linux distribution allows.
