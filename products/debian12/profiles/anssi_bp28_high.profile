documentation_complete: true

title: 'ANSSI-BP-028 (high)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 v2.0 at the high hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

selections:
  - anssi:all:high
  - package_rsyslog_installed
  - service_rsyslog_enabled
  # PASS_MIN_LEN is handled by PAM on debian systems.
  - '!accounts_password_minlen_login_defs'
  # Debian uses apparmor
  - '!selinux_state'
  - '!audit_rules_mac_modification'
  - apparmor_configured
  - all_apparmor_profiles_enforced 
  - grub2_enable_apparmor
  - package_apparmor_installed
  - package_pam_apparmor_installed
  # The following are MLS related rules (not part of ANSSI-BP-028)
  - '!accounts_polyinstantiated_tmp'
  - '!accounts_polyinstantiated_var_tmp'
