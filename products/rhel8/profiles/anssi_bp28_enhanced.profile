documentation_complete: true

metadata:
    SMEs:
        - marcusburghardt
        - yuumasato

title: 'ANSSI-BP-028 (enhanced)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 v2.0 at the enhanced hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

    An English version of the ANSSI-BP-028 can also be found at the ANSSI website:
    https://cyber.gouv.fr/publications/configuration-recommendations-gnulinux-system

selections:
    - anssi:all:enhanced
    - var_password_hashing_algorithm=SHA512
    - var_password_pam_unix_rounds=65536
    - '!timer_logrotate_enabled'
    # disable R45: Enable AppArmor security profiles
    - '!apparmor_configured'
    - '!all_apparmor_profiles_enforced'
    - '!grub2_enable_apparmor'
    - '!package_apparmor_installed'
    - '!package_pam_apparmor_installed'
    # Following rules once had a prodtype incompatible with the rhel8 product
    - '!cracklib_accounts_password_pam_minlen'
    - '!sysctl_fs_protected_fifos'
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!audit_rules_privileged_commands_rmmod'
    - '!package_dracut-fips-aesni_installed'
    - '!audit_rules_privileged_commands_modprobe'
    - '!chronyd_configure_pool_and_server'
    - '!accounts_passwords_pam_tally2'
    - '!cracklib_accounts_password_pam_ucredit'
    - '!cracklib_accounts_password_pam_dcredit'
    - '!cracklib_accounts_password_pam_lcredit'
    - '!sysctl_fs_protected_regular'
    - '!grub2_mds_argument'
    - '!cracklib_accounts_password_pam_ocredit'
    - '!grub2_page_alloc_shuffle_argument'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!audit_rules_privileged_commands_insmod'
    - '!ensure_oracle_gpgkey_installed'
    - '!package_kea_removed'
