documentation_complete: true

title: 'ANSSI-BP-028 (high)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 at the high hardening
    level. ANSSI is the French National Information Security Agency, and stands for Agence
    nationale de la sécurité des systèmes d'information. ANSSI-BP-028 is a configuration
    recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

selections:
    - anssi:all:high
    # Following rules once had a prodtype incompatible with the ol9 product
    - '!kernel_config_gcc_plugin_structleak_byref_all'
    - '!partition_for_opt'
    - '!package_ypserv_removed'
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!kernel_config_refcount_full'
    - '!install_PAE_kernel_on_x86-32'
    - '!partition_for_boot'
    - '!kernel_config_legacy_vsyscall_none'
    - '!kernel_config_hardened_usercopy_fallback'
    - '!ensure_redhat_gpgkey_installed'
    - '!aide_periodic_checking_systemd_timer'
    - '!sudo_add_ignore_dot'
    - '!kernel_config_gcc_plugin_latent_entropy'
    - '!audit_rules_privileged_commands_rmmod'
    - '!audit_rules_privileged_commands_modprobe'
    - '!partition_for_usr'
    - '!package_dracut-fips-aesni_installed'
    - '!kernel_config_bug_on_data_corruption'
    - '!cracklib_accounts_password_pam_lcredit'
    - '!kernel_config_stackprotector_strong'
    - '!kernel_config_sched_stack_end_check'
    - '!cracklib_accounts_password_pam_ocredit'
    - '!enable_pam_namespace'
    - '!kernel_config_gcc_plugin_stackleak'
    - '!audit_rules_privileged_commands_insmod'
    - '!kernel_config_legacy_vsyscall_emulate'
    - '!kernel_config_arm64_sw_ttbr0_pan'
    - '!kernel_config_page_poisoning'
    - '!package_ypbind_removed'
    - '!service_chronyd_or_ntpd_enabled'
    - '!sudo_dedicated_group'
    - '!chronyd_configure_pool_and_server'
    - '!accounts_passwords_pam_tally2'
    - '!cracklib_accounts_password_pam_ucredit'
    - '!kernel_config_vmap_stack'
    - '!kernel_config_legacy_vsyscall_xonly'
    - '!kernel_config_gcc_plugin_randstruct'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!sudo_add_umask'
    - '!sudo_add_env_reset'
    - '!kernel_config_stackprotector'
    - '!kernel_config_slab_freelist_hardened'
    - '!kernel_config_gcc_plugin_structleak'
    - '!cracklib_accounts_password_pam_minlen'
    - '!kernel_config_debug_wx'
    - '!kernel_config_strict_kernel_rwx'
    - '!kernel_config_fortify_source'
    - '!cracklib_accounts_password_pam_dcredit'
    - '!kernel_config_slab_merge_default'
    - '!kernel_config_slab_freelist_random'
    - '!kernel_config_hardened_usercopy'
    - '!kernel_config_strict_module_rwx'
    - '!kernel_config_modify_ldt_syscall'
