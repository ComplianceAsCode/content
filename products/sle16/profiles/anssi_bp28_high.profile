---
documentation_complete: true

metadata:
    SMEs:
        - svet-se
        - teacup-on-rockingchair

title: 'ANSSI-BP-028 (high)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 v2.0 at the high hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

    An English version of the ANSSI-BP-028 can also be found at the ANSSI website:
    https://messervices.cyber.gouv.fr/guides/en-configuration-recommendations-gnulinux-system

selections:
    - anssi:all:high
    - var_multiple_time_servers=suse
    - var_multiple_time_pools=suse
    - var_sudo_dedicated_group=root
    - accounts_password_pam_pwhistory_remember
    - set_password_hashing_min_rounds_logindefs
    - '!accounts_password_pam_dcredit'
    - '!accounts_password_pam_lcredit'
    - '!accounts_password_pam_minclass'
    - '!accounts_password_pam_minlen'
    - '!accounts_password_pam_ocredit'
    - '!accounts_password_pam_retry'
    - '!accounts_password_pam_ucredit'
    - '!accounts_password_pam_unix_remember'
    - '!accounts_password_pam_unix_rounds_password_auth'
    - '!accounts_password_pam_unix_rounds_system_auth'
    - '!accounts_passwords_pam_faillock_deny_root'
    - '!accounts_passwords_pam_faillock_deny'
    - '!accounts_passwords_pam_faillock_interval'
    - '!accounts_passwords_pam_faillock_unlock_time'
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!accounts_passwords_pam_tally2'
    - '!aide_periodic_cron_checking'
    - '!all_apparmor_profiles_enforced'
    - '!apparmor_configured'
    - '!audit_rules_dac_modification_fchmodat2'
    - '!audit_rules_file_deletion_events_renameat2'
    - '!audit_rules_immutable'
    - '!audit_rules_mac_modification_etc_selinux'
    - '!dnf-automatic_apply_updates'
    - '!dnf-automatic_security_updates_only'
    - '!enable_authselect'
    - '!ensure_almalinux_gpgkey_installed'
    - '!ensure_oracle_gpgkey_installed'
    - '!ensure_redhat_gpgkey_installed'
    - '!file_groupowner_etc_chrony_keys'
    - '!file_groupowner_user_cfg'
    - '!file_owner_user_cfg'
    - '!file_permissions_sudo'
    - '!file_permissions_user_cfg'
    - '!grub2_enable_apparmor'
    - '!grub2_mds_argument'
    - '!grub2_page_alloc_shuffle_argument'
    - '!grub2_page_poison_argument'
    - '!grub2_pti_argument'
    - '!grub2_slub_debug_argument'
    - '!kernel_config_arm64_sw_ttbr0_pan'
    - '!kernel_config_bug_on_data_corruption'
    - '!kernel_config_debug_wx'
    - '!kernel_config_fortify_source'
    - '!kernel_config_gcc_plugin_latent_entropy'
    - '!kernel_config_gcc_plugin_randstruct'
    - '!kernel_config_gcc_plugin_stackleak'
    - '!kernel_config_gcc_plugin_structleak_byref_all'
    - '!kernel_config_gcc_plugin_structleak'
    - '!kernel_config_hardened_usercopy_fallback'
    - '!kernel_config_hardened_usercopy'
    - '!kernel_config_legacy_vsyscall_emulate'
    - '!kernel_config_legacy_vsyscall_none'
    - '!kernel_config_legacy_vsyscall_xonly'
    - '!kernel_config_modify_ldt_syscall'
    - '!kernel_config_page_poisoning'
    - '!kernel_config_refcount_full'
    - '!kernel_config_sched_stack_end_check'
    - '!kernel_config_slab_freelist_hardened'
    - '!kernel_config_slab_freelist_random'
    - '!kernel_config_slab_merge_default'
    - '!kernel_config_stackprotector_strong'
    - '!kernel_config_stackprotector'
    - '!kernel_config_strict_kernel_rwx'
    - '!kernel_config_strict_module_rwx'
    - '!kernel_config_vmap_stack'
    - '!ldap_client_start_tls'
    - '!ldap_client_tls_cacertpath'
    - '!mount_option_tmp_noexec'
    - '!no_nis_in_nsswitch'
    - '!package_apparmor_installed'
    - '!package_dnf-automatic_installed'
    - '!package_dracut-fips-aesni_installed'
    - '!package_kea_removed'
    - '!package_pam_apparmor_installed'
    - '!package_rsh_removed'
    - '!package_rsh-server_removed'
    - '!package_sendmail_removed'
    - '!package_sequoia-sq_installed'
    - '!package_talk_removed'
    - '!package_talk-server_removed'
    - '!package_xinetd_removed'
    - '!package_ypbind_removed'
    - '!package_ypserv_removed'
    - '!sebool_secure_mode_insmod'
    - '!service_chronyd_enabled'
    - '!set_password_hashing_algorithm_systemauth'
    - '!sysctl_fs_protected_fifos'
    - '!sysctl_fs_protected_regular'
    - '!sysctl_kernel_unprivileged_bpf_disabled'
    - '!sysctl_kernel_yama_ptrace_scope'
    - '!sysctl_net_core_bpf_jit_harden'
    - '!sysctl_net_ipv4_conf_all_drop_gratuitous_arp'
    - '!sysctl_net_ipv6_conf_all_autoconf'
    - '!timer_dnf-automatic_enabled'
