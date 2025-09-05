documentation_complete: true

title: 'DRAFT - ANSSI-BP-028 (minimal)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 at the minimal hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

selections:
  - anssi:all:minimal

  # Following rules once had a prodtype incompatible with the rhcos4 product
  - '!package_ypserv_removed'
  - '!accounts_password_pam_dcredit'
  - '!accounts_passwords_pam_tally2_deny_root'
  - '!security_patches_up_to_date'
  - '!accounts_passwords_pam_faillock_deny'
  - '!accounts_password_pam_unix_rounds_password_auth'
  - '!accounts_passwords_pam_faillock_unlock_time'
  - '!accounts_passwords_pam_faillock_interval'
  - '!file_permissions_ungroupowned'
  - '!set_password_hashing_algorithm_systemauth'
  - '!package_tftp-server_removed'
  - '!package_rsh_removed'
  - '!package_dnf-automatic_installed'
  - '!no_files_unowned_by_user'
  - '!accounts_passwords_pam_faillock_deny_root'
  - '!accounts_password_pam_ocredit'
  - '!accounts_password_pam_lcredit'
  - '!dnf-automatic_security_updates_only'
  - '!cracklib_accounts_password_pam_lcredit'
  - '!dnf-automatic_apply_updates'
  - '!cracklib_accounts_password_pam_ocredit'
  - '!package_telnet-server_removed'
  - '!package_talk_removed'
  - '!accounts_password_pam_minlen'
  - '!package_talk-server_removed'
  - '!package_ypbind_removed'
  - '!accounts_password_pam_unix_rounds_system_auth'
  - '!timer_dnf-automatic_enabled'
  - '!accounts_passwords_pam_tally2'
  - '!cracklib_accounts_password_pam_ucredit'
  - '!accounts_password_pam_unix_remember'
  - '!file_permissions_unauthorized_sgid'
  - '!ensure_gpgcheck_local_packages'
  - '!accounts_passwords_pam_tally2_unlock_time'
  - '!enable_authselect'
  - '!cracklib_accounts_password_pam_minlen'
  - '!package_dhcp_removed'
  - '!package_telnet_removed'
  - '!dir_perms_world_writable_root_owned'
  - '!cracklib_accounts_password_pam_dcredit'
  - '!package_xinetd_removed'
  - '!ensure_gpgcheck_globally_activated'
  - '!package_tftp_removed'
  - '!package_rsh-server_removed'
  - '!accounts_password_pam_ucredit'
  - '!file_permissions_unauthorized_suid'
  - '!ensure_gpgcheck_never_disabled'
  - '!ensure_oracle_gpgkey_installed'
