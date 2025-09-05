documentation_complete: true

title: 'DRAFT - ANSSI DAT-NT28 (enhanced)'

description: 'Draft profile for ANSSI compliance at the enhanced level. ANSSI stands for Agence nationale de la sécurité des
    systèmes d''information. Based on https://www.ssi.gouv.fr/.'

extends: anssi_nt28_intermediary

selections:
    # ==============================================
    # R3 - Principle of least privilege
    # The services and executables available on the system must be analyzed in
    # order to know the privileges associated with them, and must then be
    # configured and integrated to use the bare necessities.

    # ==============================================
    # R6 - Network services partitioning
    # Network services should as much as possible be hosted on isolated environments.
    # This avoids having other potentially affected services if one of them gets
    # compromised under the same environment.

    # ==============================================
    # R7 - Logging of service activity
    # The activities of the running system and services must be logged and
    # archived on an external, non-local system.

    # ==============================================
    # R13 - Access Restrictions on System.map files
    # When the /boot partition cannot be dismounted (or it does not exist),
    # the file(s) System.map must be read restricted to root only.
    - file_permissions_systemmap

    # ==============================================
    # R16 - Hardened package repositories
    # When the distribution provides several types of repositories, preference
    # should be given to those containing packages subject to additional
    # hardening measures.
    # Between two packages providing the same service, those subject to hardening
    # (at compilation, installation, or default configuration) must be preferred.

    # ==============================================
    # R17 - Boot loader password
    # A boot loader to protect the password boot must be to be privileged.
    # This password must prevent any user from changing their configuration options.
    - grub2_password
    - grub2_uefi_password

    # ==============================================
    # R20 - Installation of secret or trusted elements
    # All secret elements or those contributing to the authentication mechanisms
    # must be set up as soon as the system is installed: account and administration
    # passwords, root authority certificates, public keys, or certificates of the
    # host (and their respective private key).

    # ==============================================
    # R24 - Disabling the loading of kernel modules
    # The loading of the kernel modules can be blocked by the activation of the
    # sysctl kernel.modules_disabledconf:
    # Prohibition of loading modules (except those already loaded to this point)
    # kernel.modules_disabled = 1

    # ==============================================
    # R25 - Yama module sysctl configuration
    # It is recommended to load the Yama security module at startup (by example
    # passing the security = yama argument to the kernel) and configure the
    # sysctl kernel.yama.ptrace_scope to a value of at least 1.
    - sysctl_kernel_yama_ptrace_scope

    # ==============================================
    # R26 - Disabling unused user accounts
    # Unused user accounts must be disabled at the system level.

    # ==============================================
    # R28 - Uniqueness and exclusivity of system service accounts
    # Each service must have its own system account and be dedicated to it exclusively.

    # ==============================================
    # R29 - User session timeout
    # Remote user sessions (shell access, graphical clients) must be closed
    # after a certain period of inactivity.
    - accounts_tmout
    - sshd_set_idle_timeout
    - sshd_idle_timeout_value=5_minutes
    - sshd_set_keepalive

    # ==============================================
    # R35 - umask value
    # The system umask must be set to 0027 (by default, any created file can
    # only be read by the user and his group, and be editable only by his owner).
    # The umask for users must be set to 0077 (any file created by a user is
    # readable and editable only by him).
    - var_accounts_user_umask=077
    - accounts_umask_etc_login_defs
    - accounts_umask_etc_profile

    # ==============================================
    # R38 - Executable setuid root
    # Setuid executables should be as small as possible. When it is expected
    # that only the administrators of the machine execute them, the setuid bit
    # must be removed and prefer them commands like su or sudo, which can be monitored
    - file_permissions_unauthorized_suid
    - file_permissions_unauthorized_sgid

    # ==============================================
    # R50 - Logging activity by auditd
    # The logging of the system activity must be done through the auditd service.

    # ==============================================
    # R53 - Restricting access of deployed services
    # The deployed services must have their access restricted to the system
    # strict minimum, especially when it comes to files, processes or network.

    # ==============================================
    # R54 - Virtualization components hardening
    # Each component supporting the virtualization must be hardened, especially
    # by applying technical measures to counter the exploit attempts.

    # ==============================================
    # R61 - Limiting the number of commands requiring the use of the EXEC option
    # The commands requiring the execution of sub-processes (EXEC tag) must be
    # explicitly listed and their use should be reduced to a strict minimum.
