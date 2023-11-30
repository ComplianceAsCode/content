documentation_complete: true

title: 'ANSSI-BP-028 (intermediary)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 v2.0 at the intermediary hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

# selinux_state: not applicable
# postfix_client_configure_mail_alias: not applicable. should be exim
# grub2_l1tf_argument debian kernels are not vulnerable, but switching from
# conditional cache flush to force mode prevent protection disabling.

selections:
  - anssi:all:intermediary
  # PASS_MIN_LEN is handled by PAM on debian systems.
  - '!accounts_password_minlen_login_defs'
  # Debian uses apparmor
  - '!selinux_state'
  # The following are MLS related rules (not part of ANSSI-BP-028)
  - '!accounts_polyinstantiated_tmp'
  - '!accounts_polyinstantiated_var_tmp'
