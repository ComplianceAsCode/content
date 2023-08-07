# platform = multi_platform_sle,multi_platform_ubuntu

{{%- if product in ['ubuntu2004'] %}}
  {{%- set utmp_path = "/var/run/utmp" %}}
{{%- else %}}
  {{%- set utmp_path = "/run/utmp" %}}
{{% endif %}}

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_fix_audit_watch_rule("auditctl", utmp_path, "wa", "session") }}}
{{{ bash_fix_audit_watch_rule("augenrules", utmp_path, "wa", "session") }}}
