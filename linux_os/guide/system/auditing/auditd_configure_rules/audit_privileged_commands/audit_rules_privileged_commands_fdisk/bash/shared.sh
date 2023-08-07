# platform = multi_platform_ubuntu

{{%- if product in ['ubuntu2004'] %}}
    {{%- set fdisk_path = "/usr/sbin/fdisk" %}}
{{%- else %}}
    {{%- set fdisk_path = "/sbin/fdisk" %}}
{{% endif %}}

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_fix_audit_watch_rule("auditctl", fdisk_path, "x", "modules") }}}
{{{ bash_fix_audit_watch_rule("augenrules", fdisk_path, "x", "modules") }}}
