documentation_complete: true

metadata:
    version: 1.0
    SMEs:
        - svet-se
        - rumch-se
        - teacup-on-rockingchair

reference: not_publicly_available

title: 'DRAFT General System Security Profile for SUSE Linux Enterprise (SLES) 16'

description: |-
    This profile contains configuration checks that align to the
    General System Security Profile for SUSE Linux Enterprise (SLES) 16.

selections:
    - base_sle16:all
    - package_libselinux_installed
    - no_shelllogin_for_systemaccounts
    - grub2_spectre_v2_argument
    - grub2_nosmep_argument_absent
    - grub2_audit_argument
    - directory_access_var_log_audit
