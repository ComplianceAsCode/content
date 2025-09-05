documentation_complete: true

metadata:
    SMEs:
        - marcusburghardt
        - yuumasato

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
    - var_password_hashing_algorithm=SHA512
    - var_password_pam_unix_rounds=65536
    # the following rule renders UEFI systems unbootable
    - '!sebool_secure_mode_insmod'
    - '!timer_logrotate_enabled'
    # disable R45: Enable AppArmor security profiles
    - '!apparmor_configured'
    - '!all_apparmor_profiles_enforced'
    - '!grub2_enable_apparmor'
    - '!package_apparmor_installed'
    - '!package_pam_apparmor_installed'
    # Following rules once had a prodtype incompatible with the rhel8 product
    - '!kernel_config_gcc_plugin_structleak_byref_all'
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!aide_periodic_checking_systemd_timer'
    - '!audit_rules_privileged_commands_rmmod'
    - '!grub2_mds_argument'
    - '!audit_rules_privileged_commands_modprobe'
    - '!package_dracut-fips-aesni_installed'
    - '!cracklib_accounts_password_pam_lcredit'
    - '!sysctl_fs_protected_regular'
    - '!cracklib_accounts_password_pam_ocredit'
    - '!kernel_config_gcc_plugin_stackleak'
    - '!audit_rules_privileged_commands_insmod'
    - '!chronyd_configure_pool_and_server'
    - '!accounts_passwords_pam_tally2'
    - '!cracklib_accounts_password_pam_ucredit'
    - '!kernel_config_legacy_vsyscall_xonly'
    - '!kernel_config_gcc_plugin_randstruct'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!cracklib_accounts_password_pam_minlen'
    - '!sysctl_fs_protected_fifos'
    - '!cracklib_accounts_password_pam_dcredit'
    - '!grub2_page_alloc_shuffle_argument'
    - '!ensure_oracle_gpgkey_installed'
    - '!ensure_almalinux_gpgkey_installed'
    - '!package_kea_removed'
