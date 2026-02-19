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
    - '!dnf-automatic_apply_updates'
    - '!dnf-automatic_security_updates_only'
    - '!enable_authselect'
    - '!ensure_almalinux_gpgkey_installed'
    - '!ensure_oracle_gpgkey_installed'
    - '!ensure_redhat_gpgkey_installed'
    - '!file_groupowner_etc_chrony_keys'
    - '!grub2_mds_argument'
    - '!grub2_page_alloc_shuffle_argument'
    - '!grub2_page_poison_argument'
    - '!grub2_pti_argument'
    - '!grub2_slub_debug_argument'
    - '!ldap_client_start_tls'
    - '!ldap_client_tls_cacertpath'
    - '!mount_option_tmp_noexec'
    - '!no_nis_in_nsswitch'
    - '!package_dnf-automatic_installed'
    - '!package_kea_removed'
    - '!package_rsh_removed'
    - '!package_rsh-server_removed'
    - '!package_sendmail_removed'
    - '!package_sequoia-sq_installed'
    - '!package_talk_removed'
    - '!package_talk-server_removed'
    - '!package_xinetd_removed'
    - '!package_ypbind_removed'
    - '!package_ypserv_removed'
    - '!set_password_hashing_algorithm_systemauth'
    - '!sysctl_fs_protected_fifos'
    - '!sysctl_fs_protected_regular'
    - '!sysctl_kernel_unprivileged_bpf_disabled'
    - '!sysctl_kernel_yama_ptrace_scope'
    - '!sysctl_net_core_bpf_jit_harden'
    - '!sysctl_net_ipv4_conf_all_drop_gratuitous_arp'
    - '!sysctl_net_ipv6_conf_all_autoconf'
    - '!timer_dnf-automatic_enabled'
