documentation_complete: true

title: 'CIS Debian 12 Benchmark Level 1 Server - Adaptado ULPGC'

description: |-
    Este perfil contiene la configuración de seguridad para el nivel 1 de CIS
    adaptada para los servidores de la ULPGC, excluyendo la monitorización de AIDE.

extends: cis_level1_server

selections:
    # El símbolo '!' le dice al compilador: "De todo lo que heredes, quita estas reglas"
    - '!package_aide_installed'
    - '!aide_build_database'
    - '!aide_periodic_checking_systemd_timer'
