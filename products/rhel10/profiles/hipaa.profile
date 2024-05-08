documentation_complete: true

metadata:
    SMEs:
        - jjaswanson4

reference: https://www.hhs.gov/hipaa/for-professionals/index.html

title: 'Health Insurance Portability and Accountability Act (HIPAA)'

description: |-
    The HIPAA Security Rule establishes U.S. national standards to protect individuals’
    electronic personal health information that is created, received, used, or
    maintained by a covered entity. The Security Rule requires appropriate
    administrative, physical and technical safeguards to ensure the
    confidentiality, integrity, and security of electronic protected health
    information.

    This profile configures Red Hat Enterprise Linux 9 to the HIPAA Security
    Rule identified for securing of electronic protected health information.
    Use of this profile in no way guarantees or makes claims against legal compliance against the HIPAA Security Rule(s).

selections:
    - hipaa:all
    - '!coreos_disable_interactive_boot'
    - '!coreos_audit_option'
    - '!coreos_nousb_kernel_argument'
    - '!coreos_enable_selinux_kernel_argument'
    - '!ensure_suse_gpgkey_installed'
    - '!ensure_fedora_gpgkey_installed'
    - '!grub2_uefi_admin_username'
    - '!grub2_uefi_pass'
    - '!service_zebra_disabled'
    - '!package_talk-server_removed'
    - '!package_talk_removed'
    - '!sshd_use_approved_macs'
    - '!sshd_use_approved_ciphers'
    - '!accounts_passwords_pam_tally2'
    - '!package_audit-audispd-plugins_installed'
    - '!package_ypserv_removed'
    - '!package_ypbind_removed'
    - '!package_xinetd_removed'
    - '!package_rsh_removed'
    - '!package_rsh-server_removed'
