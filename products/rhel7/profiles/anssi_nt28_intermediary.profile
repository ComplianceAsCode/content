documentation_complete: true

metadata:
    SMEs:
        - marcusburghardt

title: 'ANSSI-BP-028 (intermediary)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 v2.0 at the intermediary hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

    An English version of the ANSSI-BP-028 can also be found at the ANSSI website:
    https://cyber.gouv.fr/publications/configuration-recommendations-gnulinux-system

selections:
    - anssi:all:intermediary
    # Following rules once had a prodtype incompatible with the rhel7 product
    - '!accounts_passwords_pam_tally2_deny_root'
    - '!sysctl_kernel_unprivileged_bpf_disabled'
    - '!package_dnf-automatic_installed'
    - '!grub2_mds_argument'
    - '!dnf-automatic_security_updates_only'
    - '!cracklib_accounts_password_pam_lcredit'
    - '!sysctl_fs_protected_regular'
    - '!dnf-automatic_apply_updates'
    - '!cracklib_accounts_password_pam_ocredit'
    - '!sysctl_net_ipv4_conf_all_drop_gratuitous_arp'
    - '!timer_dnf-automatic_enabled'
    - '!accounts_passwords_pam_tally2'
    - '!cracklib_accounts_password_pam_ucredit'
    - '!accounts_passwords_pam_tally2_unlock_time'
    - '!enable_authselect'
    - '!cracklib_accounts_password_pam_minlen'
    - '!sysctl_fs_protected_fifos'
    - '!cracklib_accounts_password_pam_dcredit'
    - '!grub2_page_alloc_shuffle_argument'
    - '!sysctl_net_core_bpf_jit_harden'
    - '!grub2_pti_argument'
    - '!ensure_oracle_gpgkey_installed'
