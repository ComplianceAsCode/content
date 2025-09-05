documentation_complete: true

title: 'ANSSI-BP-028 (high)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 v2.0 at the high hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

selections:
    - anssi:all:high
    # Following rules once had a prodtype incompatible with the ol8 product
    - '!kernel_config_gcc_plugin_structleak_byref_all'
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!kernel_config_refcount_full'
    - '!timer_logrotate_enabled'
    - '!kernel_config_legacy_vsyscall_none'
    - '!kernel_config_hardened_usercopy_fallback'
    - '!ensure_redhat_gpgkey_installed'
    - '!aide_periodic_checking_systemd_timer'
    - '!kernel_config_gcc_plugin_latent_entropy'
    - '!audit_rules_privileged_commands_rmmod'
    - '!grub2_mds_argument'
    - '!audit_rules_privileged_commands_modprobe'
    - '!package_dracut-fips-aesni_installed'
    - '!kernel_config_bug_on_data_corruption'
    - '!cracklib_accounts_password_pam_lcredit'
    - '!sysctl_fs_protected_regular'
    - '!kernel_config_stackprotector_strong'
    - '!cracklib_accounts_password_pam_ocredit'
    - '!kernel_config_sched_stack_end_check'
    - '!kernel_config_gcc_plugin_stackleak'
    - '!audit_rules_privileged_commands_insmod'
    - '!kernel_config_legacy_vsyscall_emulate'
    - '!kernel_config_arm64_sw_ttbr0_pan'
    - '!kernel_config_page_poisoning'
    - '!chronyd_configure_pool_and_server'
    - '!accounts_passwords_pam_tally2'
    - '!cracklib_accounts_password_pam_ucredit'
    - '!kernel_config_vmap_stack'
    - '!kernel_config_legacy_vsyscall_xonly'
    - '!kernel_config_gcc_plugin_randstruct'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!kernel_config_stackprotector'
    - '!kernel_config_slab_freelist_hardened'
    - '!kernel_config_gcc_plugin_structleak'
    - '!cracklib_accounts_password_pam_minlen'
    - '!kernel_config_debug_wx'
    - '!sysctl_fs_protected_fifos'
    - '!kernel_config_strict_kernel_rwx'
    - '!kernel_config_fortify_source'
    - '!cracklib_accounts_password_pam_dcredit'
    - '!kernel_config_slab_merge_default'
    - '!kernel_config_slab_freelist_random'
    - '!kernel_config_hardened_usercopy'
    - '!grub2_page_alloc_shuffle_argument'
    - '!kernel_config_strict_module_rwx'
    - '!kernel_config_modify_ldt_syscall'
