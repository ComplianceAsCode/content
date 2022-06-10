documentation_complete: true

metadata:
    SMEs:
        - abergmann

title: 'ANSSI-BP-028 (minimal)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 v1.2 at the minimal hardening level.

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
  - anssi_sle:all:minimal
  - file_owner_etc_gshadow
  - file_owner_etc_shadow
  - file_permissions_etc_passwd
  - file_permissions_etc_group
  - file_permissions_etc_gshadow
  - file_permissions_unauthorized_world_writable
  - package_tftp-server_removed
  - sysctl_net_ipv4_conf_default_accept_redirects
  - sysctl_net_ipv4_conf_default_accept_source_route
  - sshd_disable_root_login
  - sshd_set_keepalive
  - file_permissions_sshd_private_key
  - sysctl_net_ipv4_conf_default_accept_redirects
  - sysctl_net_ipv4_conf_default_accept_source_route
