documentation_complete: true

title: 'ANSSI-BP-028 (enhanced)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 v2.0 at the enhanced hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

selections:
    - anssi:all:enhanced
    # Following rules once had a prodtype incompatible with the ol8 product
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!timer_logrotate_enabled'
    - '!ensure_redhat_gpgkey_installed'
    - '!audit_rules_privileged_commands_rmmod'
    - '!grub2_mds_argument'
    - '!audit_rules_privileged_commands_modprobe'
    - '!package_dracut-fips-aesni_installed'
    - '!cracklib_accounts_password_pam_lcredit'
    - '!sysctl_fs_protected_regular'
    - '!cracklib_accounts_password_pam_ocredit'
    - '!audit_rules_privileged_commands_insmod'
    - '!chronyd_configure_pool_and_server'
    - '!accounts_passwords_pam_tally2'
    - '!cracklib_accounts_password_pam_ucredit'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!cracklib_accounts_password_pam_minlen'
    - '!sysctl_fs_protected_fifos'
    - '!cracklib_accounts_password_pam_dcredit'
    - '!grub2_page_alloc_shuffle_argument'
