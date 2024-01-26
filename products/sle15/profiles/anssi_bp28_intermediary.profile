documentation_complete: true

metadata:
    SMEs:
        - abergmann

title: 'ANSSI-BP-028 (intermediary)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 v2.0 at the intermediary hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

    Only the components strictly necessary to the service provided by the system should be installed.
    Those whose presence can not be justified should be disabled, removed or deleted.
    Performing a minimal install is a good starting point, but doesn't provide any assurance
    over any package installed later.
    Manual review is required to assess if the installed services are minimal.

selections:
  - anssi:all:intermediary
  - var_multiple_time_servers=suse
  - var_multiple_time_pools=suse
  - var_sudo_dedicated_group=root
  - '!accounts_password_pam_unix_rounds_system_auth'
  - '!accounts_password_pam_unix_rounds_password_auth'
  -  set_password_hashing_min_rounds_logindefs
  # Following rules once had a prodtype incompatible with the sle15 product
  - '!accounts_password_pam_dcredit'
  - '!sysctl_kernel_unprivileged_bpf_disabled'
  - '!accounts_passwords_pam_faillock_deny'
  - '!ensure_redhat_gpgkey_installed'
  - '!accounts_passwords_pam_faillock_unlock_time'
  - '!accounts_passwords_pam_faillock_interval'
  - '!sysctl_kernel_yama_ptrace_scope'
  - '!grub2_mds_argument'
  - '!accounts_passwords_pam_faillock_deny_root'
  - '!accounts_password_pam_ocredit'
  - '!accounts_password_pam_lcredit'
  - '!grub2_slub_debug_argument'
  - '!sysctl_fs_protected_regular'
  - '!accounts_password_pam_minlen'
  - '!sysctl_net_ipv4_conf_all_drop_gratuitous_arp'
  - '!grub2_page_poison_argument'
  - '!enable_authselect'
  - '!sysctl_fs_protected_fifos'
  - '!grub2_page_alloc_shuffle_argument'
  - '!accounts_password_pam_ucredit'
  - '!sysctl_net_core_bpf_jit_harden'
  - '!sysctl_net_ipv6_conf_all_autoconf'
  - '!grub2_pti_argument'
  - '!ensure_oracle_gpgkey_installed'
