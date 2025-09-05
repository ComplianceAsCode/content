documentation_complete: true

metadata:
    SMEs:
        - marcusburghardt

title: 'ANSSI-BP-028 (high)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 v2.0 at the high hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

    An English version of the ANSSI-BP-028 can also be found at the ANSSI website:
    https://cyber.gouv.fr/publications/configuration-recommendations-gnulinux-system

selections:
    - anssi:all:high
    - '!timer_logrotate_enabled'
    # Following rules once had a prodtype incompatible with the rhel7 product
    - '!kernel_config_gcc_plugin_structleak_byref_all'
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!sysctl_kernel_unprivileged_bpf_disabled'
    - '!kernel_config_legacy_vsyscall_none'
    - '!kernel_config_hardened_usercopy_fallback'
    - '!aide_periodic_checking_systemd_timer'
    - '!kernel_config_gcc_plugin_latent_entropy'
    - '!package_dnf-automatic_installed'
    - '!grub2_mds_argument'
    - '!sysctl_fs_protected_regular'
    - '!dnf-automatic_security_updates_only'
    - '!kernel_config_bug_on_data_corruption'
    - '!cracklib_accounts_password_pam_lcredit'
    - '!kernel_config_stackprotector_strong'
    - '!dnf-automatic_apply_updates'
    - '!cracklib_accounts_password_pam_ocredit'
    - '!kernel_config_sched_stack_end_check'
    - '!kernel_config_gcc_plugin_stackleak'
    - '!kernel_config_legacy_vsyscall_emulate'
    - '!kernel_config_arm64_sw_ttbr0_pan'
    - '!kernel_config_page_poisoning'
    - '!sysctl_net_ipv4_conf_all_drop_gratuitous_arp'
    - '!timer_dnf-automatic_enabled'
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
    - '!enable_authselect'
    - '!cracklib_accounts_password_pam_minlen'
    - '!kernel_config_debug_wx'
    - '!sysctl_fs_protected_fifos'
    - '!kernel_config_strict_kernel_rwx'
    - '!kernel_config_fortify_source'
    - '!cracklib_accounts_password_pam_dcredit'
    - '!kernel_config_slab_merge_default'
    - '!kernel_config_slab_freelist_random'
    - '!grub2_page_alloc_shuffle_argument'
    - '!sysctl_net_core_bpf_jit_harden'
    - '!kernel_config_strict_module_rwx'
    - '!kernel_config_modify_ldt_syscall'
    - '!grub2_pti_argument'
    - '!ensure_oracle_gpgkey_installed'
