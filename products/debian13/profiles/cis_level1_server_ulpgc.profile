documentation_complete: true

title: 'CIS Debian 13 Benchmark Level 1 Server - Adaptado ULPGC'

description: |-
    Este perfil contiene la configuración de seguridad para el nivel 1 de CIS
    adaptada para los servidores de la ULPGC, excluyendo la monitorización de AIDE.

# Copiamos la base del perfil CIS oficial
extends: cis_level1_server

selections:
    # El símbolo '!' le dice al compilador: "De todo lo que heredes, quita estas reglas"
    - '!package_aide_installed'
    - '!aide_build_database'
    - '!aide_periodic_checking_systemd_timer'
    # Sincronización horaria: usar chrony en lugar de systemd-timesyncd
    # Según CIS 2.3.3: "If systemd-timesyncd is being used, chrony should be removed
    # and this section skipped". El perfil usa chrony, por tanto se excluyen los
    # controles 2.3.2.x (configuración de systemd-timesyncd).
    - var_timesync_service=chronyd
    - '!service_timesyncd_configured'
