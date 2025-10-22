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
    - sebool_selinuxuser_execmod
    - rsyslog_remote_loghost
    - service_auditd_enabled
