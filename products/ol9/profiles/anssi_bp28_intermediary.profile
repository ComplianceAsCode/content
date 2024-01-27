documentation_complete: true

title: 'ANSSI-BP-028 (intermediary)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 at the intermediary hardening
    level. ANSSI is the French National Information Security Agency, and stands for Agence
    nationale de la sécurité des systèmes d'information. ANSSI-BP-028 is a configuration
    recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

selections:
    - anssi:all:intermediary
    # Following rules once had a prodtype incompatible with the ol9 product
    - '!package_ypbind_removed'
    - '!partition_for_opt'
    - '!cracklib_accounts_password_pam_minlen'
    - '!package_ypserv_removed'
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!accounts_passwords_pam_tally2'
    - '!cracklib_accounts_password_pam_ucredit'
    - '!cracklib_accounts_password_pam_dcredit'
    - '!cracklib_accounts_password_pam_lcredit'
    - '!partition_for_usr'
    - '!partition_for_boot'
    - '!cracklib_accounts_password_pam_ocredit'
    - '!enable_pam_namespace'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!ensure_redhat_gpgkey_installed'
    - '!sudo_add_umask'
    - '!sudo_add_ignore_dot'
    - '!sudo_add_env_reset'
