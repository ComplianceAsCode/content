documentation_complete: true

metadata:
    SMEs:
        - jjaswanson4

reference: https://www.hhs.gov/hipaa/for-professionals/index.html

title: 'Health Insurance Portability and Accountability Act (HIPAA)'

description: |-
    This is a draft profile for experimental purposes.

    The HIPAA Security Rule establishes U.S. national standards to protect individuals's
    electronic personal health information that is created, received, used, or
    maintained by a covered entity. The Security Rule requires appropriate
    administrative, physical and technical safeguards to ensure the
    confidentiality, integrity, and security of electronic protected health
    information.

    This draft profile configures Red Hat Enterprise Linux 10 to the HIPAA Security
    Rule identified for securing of electronic protected health information.
    Use of this profile in no way guarantees or makes claims against legal compliance against the HIPAA Security Rule(s).

selections:
    - hipaa:all

    # RHEL 10 uses a different rule for auditing changes to selinux configuration
    # HIPAA 164.308(a)(1)(ii)(D), 164.308(a)(3)(ii)(A), 164.308(a)(5)(ii)(C), 164.312(a)(2)(i), 164.312(b), 164.312(d) and 164.312(e)
    - '!audit_rules_mac_modification'
    - audit_rules_mac_modification_etc_selinux

    - '!coreos_disable_interactive_boot'
    - '!coreos_audit_option'
    - '!coreos_nousb_kernel_argument'
    - '!coreos_enable_selinux_kernel_argument'
    - '!dconf_gnome_remote_access_credential_prompt'
    - '!dconf_gnome_remote_access_encryption'
    - '!enable_authselect'
    - '!ensure_suse_gpgkey_installed'
    - '!ensure_fedora_gpgkey_installed'
    - '!ensure_almalinux_gpgkey_installed'
    - '!grub2_uefi_admin_username'
    - '!grub2_uefi_password'
    - '!service_ypbind_disabled'
    - '!service_zebra_disabled'
    - '!package_talk-server_removed'
    - '!package_talk_removed'
    - '!sshd_use_approved_macs'
    - '!sshd_use_approved_ciphers'
    - '!accounts_passwords_pam_tally2'
    - '!package_audit-audispd-plugins_installed'
    - '!auditd_audispd_syslog_plugin_activated'
    - '!package_ypserv_removed'
    - '!package_ypbind_removed'
    - '!package_xinetd_removed'
    - '!package_rsh_removed'
    - '!package_rsh-server_removed'
    - '!package_tcp_wrappers_removed'
    - '!package_ypbind_removed'
    - '!package_xinetd_removed'
    - '!service_xinetd_disabled'
    - '!sshd_allow_only_protocol2'
    - '!sshd_disable_kerb_auth'
    - '!sshd_disable_gssapi_auth'
    - '!service_rlogin_disabled'
    - '!service_rsh_disabled'
