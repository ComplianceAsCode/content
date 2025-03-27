# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_rhv,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu,multi_platform_debian,multi_platform_almalinux

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'

{{% if audit_watches_style == "modern" %}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/sudoers", "wa", "actions", "modern", "b32", "path") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/sudoers", "wa", "actions", "modern", "b64", "path") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/sudoers", "wa", "actions", "modern", "b32", "path") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/sudoers", "wa", "actions", "modern", "b64", "path") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/sudoers.d/", "wa", "actions", "modern", "b32", "dir") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/sudoers.d/", "wa", "actions", "modern", "b64", "dir") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/sudoers.d/", "wa", "actions", "modern", "b32", "dir") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/sudoers.d/", "wa", "actions", "modern", "b64", "dir") }}}
{{% else %}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/sudoers", "wa", "actions") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/sudoers", "wa", "actions") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/sudoers.d/", "wa", "actions") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/sudoers.d/", "wa", "actions") }}}
{{% endif %}}
