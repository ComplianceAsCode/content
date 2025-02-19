description: "This is a draft profile for experimental purposes.\nThis draft profile
    contains configurations that align to ANSSI-BP-028 v2.0 at the minimal hardening
    level.\n\nANSSI is the French National Information Security Agency, and stands
    for Agence nationale de la s\xE9curit\xE9 des syst\xE8mes d'information.\nANSSI-BP-028
    is a configuration recommendation for GNU/Linux systems.\n\nA copy of the ANSSI-BP-028
    can be found at the ANSSI website:\nhttps://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/\n\nAn
    English version of the ANSSI-BP-028 can also be found at the ANSSI website:\nhttps://cyber.gouv.fr/publications/configuration-recommendations-gnulinux-system"
extends: null
hidden: ''
status: ''
metadata:
    SMEs:
    - marcusburghardt
    - vojtapolasek
reference: null
selections:
- accounts_password_minlen_login_defs
- accounts_password_pam_dcredit
- accounts_password_pam_lcredit
- accounts_password_pam_minclass
- accounts_password_pam_minlen
- accounts_password_pam_ocredit
- accounts_password_pam_ucredit
- accounts_password_pam_unix_remember
- accounts_password_pam_unix_rounds_password_auth
- accounts_password_pam_unix_rounds_system_auth
- accounts_password_set_max_life_root
- accounts_passwords_pam_faillock_deny
- accounts_passwords_pam_faillock_deny_root
- accounts_passwords_pam_faillock_interval
- accounts_passwords_pam_faillock_unlock_time
- dir_perms_world_writable_root_owned
- dir_perms_world_writable_sticky_bits
- dnf-automatic_apply_updates
- dnf-automatic_security_updates_only
- enable_authselect
- ensure_gpgcheck_globally_activated
- ensure_gpgcheck_local_packages
- ensure_gpgcheck_never_disabled
- ensure_redhat_gpgkey_installed
- file_permissions_unauthorized_sgid
- file_permissions_unauthorized_suid
- file_permissions_unauthorized_world_writable
- file_permissions_ungroupowned
- no_files_unowned_by_user
- package_dnf-automatic_installed
- package_kea_removed
- package_telnet-server_removed
- package_telnet_removed
- package_tftp-server_removed
- package_tftp_removed
- set_password_hashing_algorithm_systemauth
- timer_dnf-automatic_enabled
- var_password_hashing_algorithm=yescrypt
- var_password_hashing_algorithm_pam=sha512
- var_password_pam_unix_rounds=11
- var_password_pam_minclass=4
- var_accounts_maximum_age_root=365
- var_password_pam_minlen=15
- var_accounts_password_minlen_login_defs=15
- var_password_pam_ocredit=1
- var_password_pam_dcredit=1
- var_password_pam_ucredit=1
- var_password_pam_lcredit=1
- var_accounts_passwords_pam_faillock_fail_interval=900
- var_accounts_passwords_pam_faillock_deny=3
- var_password_pam_tally2=5
- var_accounts_passwords_pam_tally2_unlock_time=1800
- var_accounts_passwords_pam_faillock_unlock_time=900
- var_password_pam_unix_remember=2
unselected_groups: []
platforms: !!set {}
cpe_names: !!set {}
platform: null
filter_rules: ''
policies:
- anssi
title: ANSSI-BP-028 (minimal)
documentation_complete: true
