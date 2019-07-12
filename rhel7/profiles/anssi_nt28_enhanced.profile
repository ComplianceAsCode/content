documentation_complete: true

title: 'DRAFT - ANSSI DAT-NT28 (enhanced)'

description: 'Draft profile for ANSSI compliance at the enhanced level. ANSSI stands for Agence nationale de la sécurité des
    systèmes d''information. Based on https://www.ssi.gouv.fr/.'

extends: anssi_nt28_intermediary

selections:
    # ==============================================
    # R38 - Executable setuid root
    - file_permissions_unauthorized_suid
    - file_permissions_unauthorized_sgid

    - rsyslog_remote_loghost

    # R13 - Access restricions on System.map files
    # When the /boot partition cannot be dismounted (or it does not exist),
    # the file(s) System.map must be read restricted to root only.
    - file_permissions_systemmap

    # R17 Boot loader password
    - grub2_password
    - grub2_uefi_password

    # R25 Yama module sysctl configuration
    - sysctl_kernel_yama_ptrace_scope

    # R29 User session timeout
    - accounts_tmout
    - sshd_set_idle_timeout

    # R35 umask value
    - accounts_umask_etc_login_defs
    - accounts_umask_etc_profile
