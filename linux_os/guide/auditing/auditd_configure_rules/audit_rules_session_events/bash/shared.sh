# platform = Red Hat Virtualization 4,multi_platform_debian,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_slmicor,multi_platform_ubuntu,multi_platform_almalinux

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{% if audit_watches_style == "modern" %}}
{{{ bash_fix_audit_watch_rule("augenrules", "/var/run/utmp", "wa", "session", "modern", "b32", "path") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/var/run/utmp", "wa", "session", "modern", "b64", "path") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/var/log/btmp", "wa", "session", "modern", "b32", "path") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/var/log/btmp", "wa", "session", "modern", "b64", "path") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/var/log/wtmp", "wa", "session", "modern", "b32", "path") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/var/log/wtmp", "wa", "session", "modern", "b64", "path") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/var/run/utmp", "wa", "session", "modern", "b32", "path") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/var/run/utmp", "wa", "session", "modern", "b64", "path") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/var/log/btmp", "wa", "session", "modern", "b32", "path") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/var/log/btmp", "wa", "session", "modern", "b64", "path") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/var/log/wtmp", "wa", "session", "modern", "b32", "path") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/var/log/wtmp", "wa", "session", "modern", "b64", "path") }}}
{{% else %}}
{{{ bash_fix_audit_watch_rule("auditctl", "/var/run/utmp", "wa", "session") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/var/run/utmp", "wa", "session") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/var/log/btmp", "wa", "session") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/var/log/btmp", "wa", "session") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/var/log/wtmp", "wa", "session") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/var/log/wtmp", "wa", "session") }}}
{{% endif %}}
