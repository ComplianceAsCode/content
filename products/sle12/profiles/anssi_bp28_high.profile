documentation_complete: true

metadata:
    SMEs:
        - abergmann

title: 'ANSSI-BP-028 (high)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 v2.0 at the high hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

    Only the components strictly necessary to the service provided by the system should be installed.
    Those whose presence can not be justified should be disabled, removed or deleted.
    Performing a minimal install is a good starting point, but doesn't provide any assurance
    over any package installed later.
    Manual review is required to assess if the installed services are minimal.

selections:
    - anssi:all:high
    - var_multiple_time_servers=suse
    - var_multiple_time_pools=suse
    - var_sudo_dedicated_group=root
    - '!accounts_password_pam_unix_rounds_system_auth'
    - '!accounts_password_pam_unix_rounds_password_auth'
    -  set_password_hashing_min_rounds_logindefs
    # Following rules once had a prodtype incompatible with the sle12 product
    - '!kernel_config_gcc_plugin_structleak_byref_all'
    - '!accounts_password_pam_dcredit'
    - '!kernel_config_refcount_full'
    - '!sysctl_kernel_unprivileged_bpf_disabled'
    - '!kernel_config_legacy_vsyscall_none'
    - '!kernel_config_hardened_usercopy_fallback'
    - '!accounts_passwords_pam_faillock_deny'
    - '!ensure_redhat_gpgkey_installed'
    - '!accounts_passwords_pam_faillock_unlock_time'
    - '!accounts_passwords_pam_faillock_interval'
    - '!kernel_config_gcc_plugin_latent_entropy'
    - '!grub2_mds_argument'
    - '!accounts_passwords_pam_faillock_deny_root'
    - '!accounts_password_pam_ocredit'
    - '!accounts_password_pam_lcredit'
    - '!grub2_slub_debug_argument'
    - '!package_dracut-fips-aesni_installed'
    - '!kernel_config_bug_on_data_corruption'
    - '!sysctl_fs_protected_regular'
    - '!kernel_config_stackprotector_strong'
    - '!kernel_config_sched_stack_end_check'
    - '!kernel_config_gcc_plugin_stackleak'
    - '!kernel_config_legacy_vsyscall_emulate'
    - '!accounts_password_pam_minlen'
    - '!kernel_config_arm64_sw_ttbr0_pan'
    - '!kernel_config_page_poisoning'
    - '!sysctl_net_ipv4_conf_all_drop_gratuitous_arp'
    - '!grub2_page_poison_argument'
    - '!kernel_config_vmap_stack'
    - '!kernel_config_legacy_vsyscall_xonly'
    - '!kernel_config_gcc_plugin_randstruct'
    - '!kernel_config_stackprotector'
    - '!kernel_config_slab_freelist_hardened'
    - '!kernel_config_gcc_plugin_structleak'
    - '!enable_authselect'
    - '!kernel_config_debug_wx'
    - '!sysctl_fs_protected_fifos'
    - '!kernel_config_fortify_source'
    - '!kernel_config_strict_kernel_rwx'
    - '!kernel_config_slab_merge_default'
    - '!kernel_config_slab_freelist_random'
    - '!kernel_config_hardened_usercopy'
    - '!grub2_page_alloc_shuffle_argument'
    - '!sysctl_net_core_bpf_jit_harden'
    - '!accounts_password_pam_ucredit'
    - '!kernel_config_strict_module_rwx'
    - '!kernel_config_modify_ldt_syscall'
    - '!sysctl_net_ipv6_conf_all_autoconf'
    - '!grub2_pti_argument'
    - '!ensure_oracle_gpgkey_installed'
