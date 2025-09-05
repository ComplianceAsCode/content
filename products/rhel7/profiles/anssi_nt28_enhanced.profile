documentation_complete: true

title: 'ANSSI-BP-028 (enhanced)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 v1.2 at the enhanced hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

selections:
    - anssi:all:enhanced
    - '!selinux_state'
