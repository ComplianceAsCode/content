documentation_complete: true

title: 'CIS Debian 13 Benchmark Level 1 Server - Adaptado ULPGC'

description: |-
    Este perfil contiene la configuración de seguridad para el nivel 1 de CIS
    adaptada para los servidores de la ULPGC, excluyendo la monitorización de AIDE.

# Copiamos la base del perfil CIS oficial
extends: cis_level1_server

selections:
    # El símbolo '!' le dice al compilador: "De todo lo que heredes, quita estas reglas"
    - sysctl_conf_symlink_etc_sysctl_d
    - '!package_aide_installed'
    - '!aide_build_database'
    - '!aide_periodic_checking_systemd_timer'
    # Sincronización horaria: usar chrony. Las reglas de systemd-timesyncd quedan
    # automáticamente inaplicables gracias a los guards de var_timesync_service.
    - var_timesync_service=chronyd
    - var_multiple_time_servers=ulpgc
    - var_multiple_time_pools=ulpgc
    # 6.1.1 (journald standalone) y 6.1.2 (syslog daemon) son excluyentes. El perfil ULPGC
    # usa syslog-ng (6.1.2), por lo que se excluyen las reglas de la ruta journald-solo.
    - '!journald_disable_forward_to_syslog'
    - '!package_systemd-journal-remote_installed'
    - '!service_systemd-journal-upload_enabled'
    - '!socket_systemd-journal-remote_disabled'
    # 6.1.2: sustituir rsyslog por syslog-ng
    - '!package_rsyslog_installed'
    - '!service_rsyslog_enabled'
    - '!rsyslog_filecreatemode'
    - '!rsyslog_nolisten'
    - package_syslogng_installed
    - service_syslogng_enabled
    - syslogng_filecreatemode
    - syslogng_nolisten
    # 5.1.4: remediación específica ULPGC — configurar AllowGroups
    - sshd_set_allow_groups
    - var_sshd_allow_groups=users
