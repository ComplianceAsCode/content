documentation_complete: true

metadata:
    SMEs:
        - marcusburghardt
        - vojtapolasek

title: 'DRAFT - ANSSI-BP-028 (minimal)'

description: |-
    This is a draft profile for experimental purposes.
    This draft profile contains configurations that align to ANSSI-BP-028 v2.0 at the minimal hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

    An English version of the ANSSI-BP-028 can also be found at the ANSSI website:
    https://cyber.gouv.fr/publications/configuration-recommendations-gnulinux-system

selections:
    - anssi:all:minimal
    # Following rules are incompatible with rhel10 product
    # tally2 is deprecated, replaced by faillock
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!accounts_passwords_pam_tally2'
    - '!accounts_passwords_pam_tally2_unlock_time'
    # pam_cracklib is not used in RHEL 10
    - '!cracklib_accounts_password_pam_minlen'
    - '!cracklib_accounts_password_pam_ucredit'
    - '!cracklib_accounts_password_pam_dcredit'
    - '!cracklib_accounts_password_pam_lcredit'
    - '!cracklib_accounts_password_pam_ocredit'
    # Non-Red Hat keys are irrelevant on RHEL 10
    - '!ensure_oracle_gpgkey_installed'
    - '!ensure_almalinux_gpgkey_installed'
    # this rule is not automated anymore
    - '!security_patches_up_to_date'
    # these packages do not exist in rhel10 (R62)
    - '!package_dhcp_removed'
    - '!package_rsh_removed'
    - '!package_rsh-server_removed'
    - '!package_sendmail_removed'
    - '!package_talk_removed'
    - '!package_talk-server_removed'
    - '!package_xinetd_removed'
    - '!package_ypbind_removed'
    - '!package_ypserv_removed'
    # these rules are failing when they are remediated with Ansible, removing then temporarily until they are fixed
    - '!accounts_password_pam_retry'
