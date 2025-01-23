documentation_complete: true

title: 'DRAFT - ANSSI-BP-028 (high)'

description: |-
    This is a draft profile for experimental purposes.
    This draft profile contains configurations that align to ANSSI-BP-028 v2.0 at the high hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

    An English version of the ANSSI-BP-028 can also be found at the ANSSI website:
    https://cyber.gouv.fr/publications/configuration-recommendations-gnulinux-system

selections:
    - anssi:all:high
    - '!package_ypserv_removed'
    - '!sebool_secure_mode_insmod'
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!install_PAE_kernel_on_x86-32'
    - '!ensure_redhat_gpgkey_installed'
    - '!ensure_almalinux_gpgkey_installed'
    - '!aide_periodic_checking_systemd_timer'
    - '!package_dracut-fips-aesni_installed'
    - '!cracklib_accounts_password_pam_lcredit'
    - '!cracklib_accounts_password_pam_ocredit'
    - '!package_ypbind_removed'
    - '!service_chronyd_or_ntpd_enabled'
    - 'service_chronyd_enabled'
    - '!accounts_passwords_pam_tally2'
    - '!cracklib_accounts_password_pam_ucredit'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!sudo_add_umask'
    - '!cracklib_accounts_password_pam_minlen'
    - '!cracklib_accounts_password_pam_dcredit'
    # this rule is not automated anymore
    - '!security_patches_up_to_date'
    # OL 10 unified the paths for grub2 files. These rules are selected in control file by R29.
    - '!file_groupowner_efi_grub2_cfg'
    - '!file_owner_efi_grub2_cfg'
    - '!file_permissions_efi_grub2_cfg'
    - '!file_groupowner_efi_user_cfg'
    - '!file_owner_efi_user_cfg'
    - '!file_permissions_efi_user_cfg'
    # disable R45: Enable AppArmor security profiles
    - '!apparmor_configured'
    - '!all_apparmor_profiles_enforced'
    - '!grub2_enable_apparmor'
    - '!package_apparmor_installed'
    - '!package_pam_apparmor_installed'
    # these packages do not exist in ol10 (R62)
    - '!package_dhcp_removed'
    - '!package_rsh_removed'
    - '!package_rsh-server_removed'
    - '!package_sendmail_removed'
    - '!package_talk_removed'
    - '!package_talk-server_removed'
    - '!package_xinetd_removed'
    # There isn't 32 bits OL
    - '!prefer_64bit_os'
    # These rules are no longer relevant
    - '!kernel_config_devkmem'
    - '!kernel_config_hardened_usercopy_fallback'
    - '!kernel_config_page_poisoning_no_sanity'
    - '!kernel_config_page_poisoning_zero'
    - '!kernel_config_page_table_isolation'
    - '!kernel_config_refcount_full'
    - '!kernel_config_retpoline'
    - '!kernel_config_security_writable_hooks'
