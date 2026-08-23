---
documentation_complete: true

metadata:
    SMEs:
        - svet-se
        - teacup-on-rockingchair

title: 'ANSSI-BP-028 (intermediary)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 v2.0 at the intermediary hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

    An English version of the ANSSI-BP-028 can also be found at the ANSSI website:
    https://messervices.cyber.gouv.fr/guides/en-configuration-recommendations-gnulinux-system

selections:
    - anssi:all:intermediary
    - var_multiple_time_servers=suse
    - var_multiple_time_pools=suse
    - var_sudo_dedicated_group=root
    - accounts_password_pam_pwhistory_remember
    - set_password_hashing_min_rounds_logindefs
    - '!cracklib_accounts_password_pam_dcredit'
    - '!cracklib_accounts_password_pam_lcredit'
    - '!cracklib_accounts_password_pam_minlen'
    - '!cracklib_accounts_password_pam_ocredit'
    - '!cracklib_accounts_password_pam_ucredit'
    - '!accounts_password_pam_unix_rounds_system_auth'
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!accounts_passwords_pam_tally2'
    - '!aide_periodic_cron_checking'
    - '!all_apparmor_profiles_enforced'
    - '!apparmor_configured'
    - '!audit_rules_immutable'
    - '!dnf-automatic_apply_updates'
    - '!dnf-automatic_security_updates_only'
    - '!enable_authselect'
    - '!ensure_almalinux_gpgkey_installed'
    - '!ensure_oracle_gpgkey_installed'
    - '!ensure_redhat_gpgkey_installed'
    - '!file_groupowner_user_cfg'
    - '!file_owner_user_cfg'
    - '!file_permissions_sudo'
    - '!file_permissions_user_cfg'
    - '!grub2_enable_apparmor'
    - '!kernel_config_arm64_sw_ttbr0_pan'
    - '!kernel_config_gcc_plugin_latent_entropy'
    - '!kernel_config_gcc_plugin_randstruct'
    - '!kernel_config_gcc_plugin_stackleak'
    - '!kernel_config_gcc_plugin_structleak_byref_all'
    - '!kernel_config_gcc_plugin_structleak'
    - '!kernel_config_legacy_vsyscall_emulate'
    - '!kernel_config_modify_ldt_syscall'
    - '!kernel_config_refcount_full'
    - '!kernel_config_slab_merge_default'
    - '!ldap_client_start_tls'
    - '!ldap_client_tls_cacertpath'
    - '!no_nis_in_nsswitch'
    - '!package_apparmor_installed'
    - '!package_dnf-automatic_installed'
    - '!package_dracut-fips-aesni_installed'
    - '!package_pam_apparmor_installed'
    - '!package_rsh_removed'
    - '!package_rsh-server_removed'
    - '!package_ypbind_removed'
    - '!package_ypserv_removed'
    - '!sebool_secure_mode_insmod'
    - '!timer_dnf-automatic_enabled'
